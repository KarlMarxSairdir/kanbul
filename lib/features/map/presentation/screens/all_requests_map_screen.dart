import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/utils/blood_compatibility.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:flutter/services.dart'; // rootBundle için

class AllRequestsMapScreen extends ConsumerStatefulWidget {
  const AllRequestsMapScreen({super.key});

  @override
  ConsumerState<AllRequestsMapScreen> createState() =>
      _AllRequestsMapScreenState();
}

class _AllRequestsMapScreenState extends ConsumerState<AllRequestsMapScreen> {
  final _c = Completer<GoogleMapController>();
  final _markers = <Marker>{};
  AsyncValue<List<BloodRequest>> _asyncRequests = const AsyncLoading();
  Position? _currentPosition;
  String? _mapStyle;
  bool _isMapStyleLoaded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    ref
        .read(bloodRequestRepositoryProvider)
        .watchAllActive()
        .listen(
          (requests) {
            setState(() {
              _markers
                ..clear()
                ..addAll(requests.map(_toMarker));
              _asyncRequests = AsyncData(requests);
            });
          },
          onError: (error) {
            setState(() {
              _asyncRequests = AsyncError(error, StackTrace.current);
            });
          },
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Sadece ilk yüklemede style'ı yükle
    if (!_isMapStyleLoaded) {
      _loadMapStyle();
    }
  }

  Future<void> _loadMapStyle() async {
    // Her zaman açık tema kullan
    const stylePath = 'assets/map_style_light.json';
    _mapStyle = await rootBundle.loadString(stylePath);
    _isMapStyleLoaded = true;
    
    // Eğer harita zaten oluşturulmuşsa style'ı güncelle
    if (_c.isCompleted) {
      final controller = await _c.future;
      await controller.setMapStyle(_mapStyle);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    if (_c.isCompleted) {
      final controller = await _c.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Marker _toMarker(BloodRequest r) {
    final user = ref.read(authStateNotifierProvider).user;
    final donorBloodType = user?.profileData.bloodType;
    final canDonate = BloodCompatibility.canDonateTo(
      donorBloodType,
      r.bloodType,
    );
    return Marker(
      markerId: MarkerId(r.id),
      position: LatLng(r.location!.latitude, r.location!.longitude),
      icon:
          canDonate
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
      infoWindow: InfoWindow(
        title: '${r.bloodType} • ${r.title}',
        snippet: canDonate ? null : 'Bu talebe kan veremezsiniz',
        onTap: () {
          if (r.id.isNotEmpty) {
            context.pushNamed(
              AppRoutes.bloodRequestDetail,
              pathParameters: {'requestId': r.id},
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktif Talepler – Harita + Liste')),
      body: Stack(
        children: [
          GoogleMap(
            style: _mapStyle,
            initialCameraPosition:
                _currentPosition != null
                    ? CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15.0,
                    )
                    : const CameraPosition(
                      target: LatLng(39.9, 32.85),
                      zoom: 5.5,
                    ),
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (c) async {
              _c.complete(c);
              
              // Map style'ı uygula
              if (_mapStyle != null) {
                await c.setMapStyle(_mapStyle);
              }
              
              if (_currentPosition != null) {
                c.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15.0,
                    ),
                  ),
                );
              }
            },
          ),
          DraggableScrollableSheet(
            maxChildSize: .65,
            initialChildSize: .25,
            builder:
                (_, scroll) => Material(
                  elevation: 6,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _asyncRequests.when(
                    data:
                        (list) => ListView.builder(
                          controller: scroll,
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final user =
                                ref.read(authStateNotifierProvider).user;
                            final donorBloodType = user?.profileData.bloodType;
                            final canDonate = BloodCompatibility.canDonateTo(
                              donorBloodType,
                              list[i].bloodType,
                            );
                            return ListTile(
                              title: Text(list[i].title),
                              subtitle: Text(
                                '${list[i].bloodType} • '
                                '${list[i].hospitalName ?? ''}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!canDonate)
                                    const Icon(
                                      Icons.block,
                                      color: Colors.blueGrey,
                                      size: 20,
                                    ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                if (list[i].id.isNotEmpty) {
                                  context.pushNamed(
                                    AppRoutes.bloodRequestDetail,
                                    pathParameters: {'requestId': list[i].id},
                                  );
                                }
                              },
                            );
                          },
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Hata: $e')),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
