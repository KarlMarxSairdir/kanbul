// lib/features/map/presentation/screens/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // YENİ
import 'package:kan_bul/data/repositories/blood_request_repository.dart'; // BloodRequestRepository provider için
import 'package:kan_bul/data/repositories/auth_repository.dart'; // AuthRepository provider için
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // Corrected import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart'; // Adres çevirisi için eklendi
import 'package:kan_bul/core/utils/location_utils.dart';
import 'package:kan_bul/core/utils/blood_compatibility.dart'; // Kan uyumluluğu için
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:flutter/services.dart'; // rootBundle için

class MapScreen extends ConsumerStatefulWidget {
  final bool isLocationSelectionMode;
  final Position? initialPosition;

  const MapScreen({
    super.key,
    this.isLocationSelectionMode = false,
    this.initialPosition,
  });

  @override
  ConsumerState<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter =
      Completer<GoogleMapController>();
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(39.9334, 32.8597),
    zoom: 5.5,
  );
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  Position? _selectedPosition;
  String? _selectedAddress;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription? _requestsSubscription;
  bool _isLoadingRequests = false;
  String? _errorMessage;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    logger.d(
      "MapScreen: initState - SelectionMode: ${widget.isLocationSelectionMode}",
    );
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition;
      if (widget.isLocationSelectionMode) {
        _selectedPosition = widget.initialPosition;
        _getAddressFromLatLng(_selectedPosition!);
        _updateSelectedMarker(_selectedPosition!);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _controllerCompleter.future;
        _goToPosition(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
      });
    } else {
      _determinePosition();
    }
    if (!widget.isLocationSelectionMode) {
      _startListeningLocation();
    }
  }

  Future<void> _loadMapStyle() async {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final stylePath =
        isDark ? 'assets/map_style_dark.json' : 'assets/map_style_light.json';
    _mapStyle = await rootBundle.loadString(stylePath);
  }

  @override
  void dispose() {
    logger.d("MapScreen: dispose");
    _positionStreamSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    logger.i("MapScreen: Konum belirleniyor...");

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('MapScreen: Konum servisleri kapalı.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen konum servislerini açın.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      logger.w('MapScreen: Konum izni reddedilmiş, izin isteniyor...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.w('MapScreen: Konum izni tekrar reddedildi.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harita özellikleri için konum izni gerekli.'),
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.w('MapScreen: Konum izni kalıcı olarak reddedilmiş.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Konum izni kalıcı olarak reddedildi. Ayarlardan açabilirsiniz.',
            ),
          ),
        );
      }
      return;
    }

    try {
      logger.d('MapScreen: Mevcut konum alınıyor...');
      Position position = await Geolocator.getCurrentPosition();
      logger.i(
        'MapScreen: Konum alındı: ${position.latitude}, ${position.longitude}',
      );
      setState(() {
        _currentPosition = position;
      });

      _saveUserLocation(position);
      _goToCurrentLocation(position);

      if (widget.isLocationSelectionMode) {
        _selectPosition(position);
      } else {
        _loadNearbyBloodRequests(position);
      }
    } catch (e, s) {
      logger.e(
        'MapScreen: Konum alınırken hata oluştu.',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum alınırken bir hata oluştu.')),
        );
      }
    }
  }

  void _startListeningLocation() {
    logger.d("MapScreen: Konum değişiklikleri dinlenmeye başlanıyor...");
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position? position) {
        if (position != null && mounted) {
          logger.t(
            'MapScreen: Konum güncellendi: ${position.latitude}, ${position.longitude}',
          );
          if (_currentPosition == null ||
              _currentPosition!.latitude != position.latitude ||
              _currentPosition!.longitude != position.longitude) {
            setState(() {
              _currentPosition = position;
              _updateUserMarker(position);
              _saveUserLocation(position);
            });
          }
        }
      },
      onError: (error) {
        logger.e("MapScreen: Konum dinleme hatası", error: error);
      },
    );
  }

  void _saveUserLocation(Position position) {
    final authStateValue = ref.read(authStateNotifierProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final userId = authStateValue.user?.id;

    if (userId != null) {
      final geoPoint = GeoPoint(position.latitude, position.longitude);

      authRepo
          .updateUserLocation(userId, geoPoint)
          .then((_) {
            logger.i("MapScreen: Kullanıcı konumu Firestore'a kaydedildi");
            ref.read(authStateNotifierProvider.notifier).refreshUser();
          })
          .catchError((e) {
            logger.e("MapScreen: Konum kaydetme hatası", error: e);
          });
    } else {
      logger.w(
        "MapScreen: Kullanıcı giriş yapmadığı için konum kaydedilemiyor",
      );
    }
  }

  Future<void> _goToPosition(LatLng position, {double zoom = 15.0}) async {
    logger.d("MapScreen: Harita pozisyonuna gidiliyor: $position, zoom: $zoom");
    final GoogleMapController controller = await _controllerCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  Future<void> _goToCurrentLocation(Position position) async {
    await _goToPosition(LatLng(position.latitude, position.longitude));

    if (!widget.isLocationSelectionMode) {
      _updateUserMarker(position);
    }
  }

  void _updateUserMarker(Position position) {
    final markerId = const MarkerId('currentUser');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: 'Siz Buradasınız'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    if (mounted) {
      setState(() {
        _markers.removeWhere((m) => m.markerId == markerId);
        _markers.add(marker);
      });
    }
  }

  void _updateSelectedMarker(Position position) {
    final markerId = const MarkerId('selectedLocation');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: 'Seçilen Konum'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      draggable: true,
      onDragEnd: (newPosition) {
        _selectPosition(
          Position(
            latitude: newPosition.latitude,
            longitude: newPosition.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          ),
        );
      },
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId == markerId);
      _markers.add(marker);
    });
  }

  void _selectPosition(Position position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateSelectedMarker(position);
    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              "${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, "
                      "${place.subLocality ?? ''} ${place.locality ?? ''}, "
                      "${place.administrativeArea ?? ''}"
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim();
        });
      }
    } catch (e) {
      logger.e("MapScreen: Adres çevirme hatası", error: e);
      setState(() {
        _selectedAddress = null;
      });
    }
  }

  Future<void> _loadNearbyBloodRequests(Position position) async {
    if (widget.isLocationSelectionMode) return;

    logger.i(
      "MapScreen: Konum bilgisi: lat=${position.latitude}, lng=${position.longitude}",
    );
    logger.i("MapScreen: Yakındaki talepleri sorguluyorum, yarıçap: 30km");
    setState(() {
      _isLoadingRequests = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(bloodRequestRepositoryProvider);
      final authState = ref.read(authStateNotifierProvider);

      final GeoPoint center = GeoPoint(position.latitude, position.longitude);
      final double radiusInKm = 30.0;

      _requestsSubscription?.cancel();

      final userBloodType = authState.user?.profileData.bloodType;

      logger.i("MapScreen: Kullanıcı kan grubu: $userBloodType");

      if (userBloodType == null) {
        logger.w(
          "MapScreen: Kullanıcı kan grubu bilgisi bulunamadı, tüm talepleri gösteriyorum",
        );
        _loadAllNearbyBloodRequests(repository, center, radiusInKm);
        return;
      }

      final compatibleTypes = BloodCompatibility.getCompatibleRecipientGroups(
        userBloodType,
      );
      logger.i(
        "MapScreen: Kullanıcının ($userBloodType) kan verebileceği gruplar: $compatibleTypes",
      );

      _requestsSubscription = repository
          .watchCompatibleNearbyActive(
            donorBloodType: userBloodType,
            center: center,
            radiusKm: radiusInKm,
          )
          .map((bloodRequests) {
            logger.i(
              "MapScreen: ${bloodRequests.length} uyumlu yakın talep bulundu.",
            );

            for (var request in bloodRequests) {
              final location = request.location;
              final bloodType = request.bloodType;

              if (location != null) {
                final double distance = LocationUtils.calculateDistanceInKm(
                  center.latitude,
                  center.longitude,
                  location.latitude,
                  location.longitude,
                );
                logger.d(
                  "MapScreen: Uyumlu Talep ID: ${request.id}, Kan grubu: $bloodType, Mesafe: ${distance.toStringAsFixed(2)}km",
                );
              }
            }

            return bloodRequests;
          })
          .listen(
            (bloodRequests) {
              setState(() {
                _isLoadingRequests = false;

                _updateBloodRequestMarkers(bloodRequests);
              });
            },
            onError: (error) {
              logger.e("MapScreen: Talep yükleme hatası", error: error);
              setState(() {
                _isLoadingRequests = false;
                _errorMessage = "Kan talepleri yüklenirken bir hata oluştu.";
              });
            },
          );
    } catch (e, s) {
      logger.e(
        "MapScreen: Talep stream başlatma hatası",
        error: e,
        stackTrace: s,
      );
      setState(() {
        _isLoadingRequests = false;
        _errorMessage = "Kan talepleri yüklenirken bir hata oluştu: $e";
      });
    }
  }

  void _loadAllNearbyBloodRequests(
    dynamic repository,
    GeoPoint center,
    double radiusInKm,
  ) {
    _requestsSubscription = repository
        .watchNearbyActive(center: center, radiusKm: radiusInKm)
        .listen(
          (requests) {
            logger.i(
              "MapScreen: ${requests.length} yakın talep bulundu (kan grubu filtrelemesi olmadan).",
            );

            setState(() {
              _isLoadingRequests = false;

              _updateBloodRequestMarkers(requests);
            });
          },
          onError: (error) {
            logger.e("MapScreen: Talep yükleme hatası", error: error);
            setState(() {
              _isLoadingRequests = false;
              _errorMessage = "Kan talepleri yüklenirken bir hata oluştu.";
            });
          },
        );
  }

  void _updateBloodRequestMarkers(List<BloodRequest> requests) {
    if (widget.isLocationSelectionMode) return;

    _markers.removeWhere(
      (marker) => marker.markerId != const MarkerId('currentUser'),
    );

    for (var request in requests) {
      if (request.location == null) continue;

      final urgency = request.urgencyLevel;
      BitmapDescriptor markerIcon;

      switch (urgency) {
        case 3:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          );
          break;
        case 2:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          );
          break;
        case 1:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          );
          break;
        default:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          );
      }

      final bloodType = request.bloodType;
      final title = request.title;
      final creatorName = request.creatorName;

      final marker = Marker(
        markerId: MarkerId(request.id),
        position: LatLng(
          request.location!.latitude,
          request.location!.longitude,
        ),
        infoWindow: InfoWindow(
          title: "$bloodType - $title",
          snippet: "Talep eden: $creatorName",
          onTap: () {
            if (request.id.isNotEmpty) {
              context.pushNamed(
                AppRoutes.bloodRequestDetail,
                pathParameters: {'requestId': request.id},
              );
            }
          },
        ),
        icon: markerIcon,
      );

      _markers.add(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("MapScreen: Build çağrıldı.");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLocationSelectionMode ? 'Konum Seç' : 'Harita'),
        actions: [
          if (!widget.isLocationSelectionMode)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Talepleri Yenile',
              onPressed:
                  _currentPosition != null
                      ? () => _loadNearbyBloodRequests(_currentPosition!)
                      : null,
            )
          else if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Konumu Onayla',
              onPressed: () {
                Navigator.of(context).pop(_selectedPosition);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:
                _currentPosition != null
                    ? CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15.0,
                    )
                    : _kInitialPosition,
            style: _mapStyle,
            onMapCreated: (GoogleMapController controller) async {
              logger.i("MapScreen: Harita oluşturuldu.");
              if (!_controllerCompleter.isCompleted) {
                _controllerCompleter.complete(controller);
              }
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(bottom: 50.0),
            onTap:
                widget.isLocationSelectionMode
                    ? (LatLng latLng) {
                      _selectPosition(
                        Position(
                          latitude: latLng.latitude,
                          longitude: latLng.longitude,
                          timestamp: DateTime.now(),
                          accuracy: 0,
                          altitude: 0,
                          altitudeAccuracy: 0,
                          heading: 0,
                          headingAccuracy: 0,
                          speed: 0,
                          speedAccuracy: 0,
                        ),
                      );
                    }
                    : null,
          ),
          if (_isLoadingRequests && !widget.isLocationSelectionMode)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
          if (_errorMessage != null && !widget.isLocationSelectionMode)
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[900]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (widget.isLocationSelectionMode && _selectedPosition != null)
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Seçilen Konum',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddress ??
                            'Koordinatlar: ${_selectedPosition!.latitude.toStringAsFixed(5)}, ${_selectedPosition!.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Farklı bir konum seçmek için haritaya dokunun veya işaretçiyi sürükleyin.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
