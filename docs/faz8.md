🚀 KanBul – Faz 8: Harita Görünümü
==========================

🎯 **Hedefler**
--------------
- Kan talepleri ve bağışçıların harita üzerinde görselleştirilmesi
- Konum bazlı eşleştirme ve filtreleme sisteminin geliştirilmesi
- En yakın hastaneler ve kan merkezlerinin haritada gösterilmesi
- Rota oluşturma ve navigasyon rehberliğinin entegrasyonu
- Harita deneyimini optimize eden etkileşim özelliklerinin eklenmesi
- Gerçek zamanlı konum güncellemeleri ve harita yenileme sisteminin kurulması

📌 **Adım 8.1: Harita Entegrasyonu ve Temel Yapı**
-----------------------------------------------
**Açıklama**
- Google Maps veya MapBox gibi harita servislerinin entegrasyonu
- Harita temel görünüm ayarları ve stil yapılandırması
- Harita izinleri ve konum erişiminin yönetimi
- Harita widget'ının uygulama içine yerleştirilmesi
- Farklı cihaz boyutlarına uygun duyarlı (responsive) tasarım

🛠 **Kullanılacak Paketler**
--------------------------
- google_maps_flutter: ^2.x.x (Google Maps için)
- mapbox_gl: ^0.16.x (MapBox alternatifi)
- location: ^4.x.x (Konum servisleri)
- geolocator: ^9.x.x (Mesafe hesaplama ve jeolokasyon)
- permission_handler: ^10.x.x (İzin yönetimi)
- flutter_polyline_points: ^1.x.x (Rota çizimi)
- geocoding: ^2.x.x (Adres ve konum dönüşümleri)

📝 **Örnek Harita Kurulum Kodu**
---------------------------
```dart
class BloodMapScreen extends StatefulWidget {
  @override
  _BloodMapScreenState createState() => _BloodMapScreenState();
}

class _BloodMapScreenState extends State<BloodMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};

  // Kullanıcının konumu
  LatLng? _currentPosition;
  bool _isLoading = true;

  // Görüntüleme filtreleri
  bool _showDonors = true;
  bool _showRequests = true;
  bool _showHospitals = true;

  // Filtreler
  BloodType? _selectedBloodType;
  double _searchRadius = 15.0; // km

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // İzin reddedildiği durumda kullanıcıya bilgi ver
        _showPermissionDeniedMessage();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kullanıcı kalıcı olarak izni reddetmiş
      _showPermanentlyDeniedMessage();
      return;
    }

    // İzin varsa konumu al
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Harita konumunu güncelle
      if (_currentPosition != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 14),
        );

        // Kullanıcı konumu marker'ı
        _addCurrentLocationMarker();

        // Yakındaki öğeleri yükle
        _loadNearbyItems();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Konum alınamadı: ${e.toString()}');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final currentLocationMarker = Marker(
      markerId: MarkerId('current_location'),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: 'Konumunuz',
        snippet: 'Şu anki konumunuz',
      ),
    );

    setState(() {
      _markers.add(currentLocationMarker);

      // Görüş alanı çemberi
      _circles.add(
        Circle(
          circleId: CircleId('search_area'),
          center: _currentPosition!,
          radius: _searchRadius * 1000, // metre cinsinden
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      );
    });
  }

  Future<void> _loadNearbyItems() async {
    if (_currentPosition == null) return;

    // Kullanıcının konumuna göre yakındaki talep, bağışçı ve hastaneleri yükle
    if (_showRequests) await _loadNearbyRequests();
    if (_showDonors) await _loadNearbyDonors();
    if (_showHospitals) await _loadNearbyHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kan Haritası'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Harita
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(41.0082, 28.9784), // Varsayılan olarak Istanbul
              zoom: 14.0,
            ),
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;

              // Harita stili ayarla (opsiyonel)
              _setMapStyle();
            },
          ),

          // Yükleme göstergesi
          if (_isLoading)
            Center(child: CircularProgressIndicator()),

          // Filtre çipleri
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildFilterChips(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          _markers.clear();
          _addCurrentLocationMarker();
          _loadNearbyItems();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text('Bağışçılar'),
              selected: _showDonors,
              onSelected: (selected) {
                setState(() {
                  _showDonors = selected;
                  _updateMarkers();
                });
              },
            ),
            SizedBox(width: 8),
            FilterChip(
              label: Text('Talepler'),
              selected: _showRequests,
              onSelected: (selected) {
                setState(() {
                  _showRequests = selected;
                  _updateMarkers();
                });
              },
            ),
            SizedBox(width: 8),
            FilterChip(
              label: Text('Hastaneler'),
              selected: _showHospitals,
              onSelected: (selected) {
                setState(() {
                  _showHospitals = selected;
                  _updateMarkers();
                });
              },
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // Diğer metodlar...
}
```

📌 **Adım 8.2: Kan Talepleri Harita Görünümü**
------------------------------------------
**Açıklama**
- Kan taleplerinin harita üzerinde işaretlenmesi
- Taleplerin kan gruplarına göre renklendirme ve simgelendirme
- Aciliyet durumlarına göre görsel farklılaştırma
- Talep detay bilgilerini gösteren bilgi pencereleri (info window)
- Kümeleme (clustering) ile yoğun bölgelerin yönetimi

**Eklenecek Özellikler**
- Talepleri kan grubuna göre filtreleme
- Aciliyete göre sıralama ve filtreleme
- Talebin zaman çerçevesine göre kategorizasyon
- Harita üzerinde talep yoğunluğu ısı haritası (heat map)
- Yakınlaşma/uzaklaşmaya duyarlı kümeleme

📝 **Örnek Kan Talebi Harita Kodları**
---------------------------------
```dart
class BloodRequestMapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Konuma göre yakındaki talepleri getir
  Future<List<BloodRequest>> getNearbyBloodRequests({
    required LatLng center,
    required double radiusKm,
    BloodType? bloodType,
    bool onlyUrgent = false,
  }) async {
    try {
      // GeoFire kullanarak konuma yakın talepleri sorgula
      final List<DocumentSnapshot> snapshots = await geoFirestore
          .collection('blood_requests')
          .within(
            center: geo.point(
              latitude: center.latitude,
              longitude: center.longitude,
            ),
            radiusInKm: radiusKm,
            field: 'location',
          )
          .get();

      if (snapshots.isEmpty) {
        return [];
      }

      // Talepleri BloodRequest nesnesine dönüştür
      List<BloodRequest> requests = snapshots
          .map((doc) => BloodRequest.fromFirestore(doc))
          .where((request) => request.status == RequestStatus.active)
          .where((request) => request.isValid)
          .toList();

      // Kan grubu filtresi
      if (bloodType != null) {
        final compatibleTypes = getCompatibleRecipientBloodTypes(bloodType);
        requests = requests
            .where((request) => compatibleTypes.contains(request.bloodType))
            .toList();
      }

      // Aciliyet filtresi
      if (onlyUrgent) {
        requests = requests
            .where((request) => request.isUrgent)
            .toList();
      }

      // Aciliyete göre sırala
      requests.sort((a, b) =>
          b.urgencyLevel.index.compareTo(a.urgencyLevel.index));

      return requests;
    } catch (e) {
      print('Yakındaki talepler alınırken hata: $e');
      return [];
    }
  }

  // Bu talepleri harita marker'larına dönüştür
  List<Marker> createBloodRequestMarkers({
    required List<BloodRequest> requests,
    required Function(BloodRequest) onTap,
  }) {
    return requests.map((request) {
      // Talep aciliyetine göre ikon rengi
      final BitmapDescriptor markerIcon = _getMarkerIconForRequest(request);

      return Marker(
        markerId: MarkerId('request_${request.id}'),
        position: LatLng(
          request.location.latitude,
          request.location.longitude,
        ),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: '${request.bloodType} Kan İhtiyacı',
          snippet: '${request.hospitalName} - ${_getUrgencyText(request.urgencyLevel)}',
        ),
        onTap: () => onTap(request),
      );
    }).toList();
  }

  // Aciliyet durumuna göre ikon rengi belirleme
  BitmapDescriptor _getMarkerIconForRequest(BloodRequest request) {
    switch (request.urgencyLevel) {
      case UrgencyLevel.veryUrgent:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case UrgencyLevel.urgent:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case UrgencyLevel.normal:
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  // Aciliyet seviyesi metni
  String _getUrgencyText(UrgencyLevel urgencyLevel) {
    switch (urgencyLevel) {
      case UrgencyLevel.veryUrgent:
        return 'Çok Acil';
      case UrgencyLevel.urgent:
        return 'Acil';
      case UrgencyLevel.normal:
      default:
        return 'Normal';
    }
  }
}
```

📌 **Adım 8.3: Bağışçı ve Hastane Konumlarını Gösterme**
---------------------------------------------------
**Açıklama**
- Aktif bağışçıların konumlarını haritada gösterme
- Hastane ve kan merkezlerinin işaretlenmesi
- Mesafeye göre görselleştirme ve filtreleme
- Bağışçıların kan gruplarına göre işaretlenmesi
- Kullanıcı gizlilik tercihlerine saygı gösteren konum paylaşımı

**Yakındaki Bağışçıları Listeleme**
- Bağışçıların konum paylaşım izinlerine göre filtreleme
- Son aktivite zamanına göre sıralama
- Bağışçı profil bilgilerine hızlı erişim
- İletişime geçme seçenekleri
- Mesafe ve tahmini varış süresi gösterimi

📝 **Örnek Bağışçı ve Hastane Gösterimi**
-----------------------------------
```dart
class DonorMapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yakındaki bağışçıları getir
  Future<List<Donor>> getNearbyDonors({
    required LatLng center,
    required double radiusKm,
    BloodType? bloodType,
  }) async {
    try {
      // GeoFire ile konuma yakın bağışçıları sorgula
      final List<DocumentSnapshot> snapshots = await geoFirestore
          .collection('users')
          .where('role', isEqualTo: 'donor')
          .where('isLocationVisible', isEqualTo: true)
          .where('isAvailableForDonation', isEqualTo: true)
          .within(
            center: geo.point(
              latitude: center.latitude,
              longitude: center.longitude,
            ),
            radiusInKm: radiusKm,
            field: 'location',
          )
          .get();

      if (snapshots.isEmpty) {
        return [];
      }

      List<Donor> donors = snapshots
          .map((doc) => Donor.fromFirestore(doc))
          .toList();

      // Kan grubu filtresi
      if (bloodType != null) {
        final compatibleTypes = getCompatibleDonorBloodTypes(bloodType);
        donors = donors
            .where((donor) => compatibleTypes.contains(donor.bloodType))
            .toList();
      }

      // Her bağışçı için mesafe hesapla
      for (var donor in donors) {
        donor.distance = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          donor.location.latitude,
          donor.location.longitude,
        ) / 1000; // km cinsinden
      }

      // Mesafeye göre sırala
      donors.sort((a, b) => a.distance.compareTo(b.distance));

      return donors;
    } catch (e) {
      print('Yakındaki bağışçılar alınırken hata: $e');
      return [];
    }
  }

  // Hastane ve kan merkezlerini getir
  Future<List<Hospital>> getNearbyHospitals({
    required LatLng center,
    required double radiusKm,
  }) async {
    try {
      // Hastaneleri sorgula
      final List<DocumentSnapshot> snapshots = await geoFirestore
          .collection('hospitals')
          .within(
            center: geo.point(
              latitude: center.latitude,
              longitude: center.longitude,
            ),
            radiusInKm: radiusKm,
            field: 'location',
          )
          .get();

      if (snapshots.isEmpty) {
        return [];
      }

      List<Hospital> hospitals = snapshots
          .map((doc) => Hospital.fromFirestore(doc))
          .toList();

      // Her hastane için mesafe hesapla
      for (var hospital in hospitals) {
        hospital.distance = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          hospital.location.latitude,
          hospital.location.longitude,
        ) / 1000; // km cinsinden
      }

      // Mesafeye göre sırala
      hospitals.sort((a, b) => a.distance.compareTo(b.distance));

      return hospitals;
    } catch (e) {
      print('Yakındaki hastaneler alınırken hata: $e');
      return [];
    }
  }

  // Bağışçı marker'ları oluştur
  List<Marker> createDonorMarkers({
    required List<Donor> donors,
    required Function(Donor) onTap,
  }) {
    return donors.map((donor) {
      return Marker(
        markerId: MarkerId('donor_${donor.id}'),
        position: LatLng(
          donor.location.latitude,
          donor.location.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '${donor.bloodType} Bağışçı',
          snippet: '${donor.distance.toStringAsFixed(1)} km uzaklıkta',
        ),
        onTap: () => onTap(donor),
      );
    }).toList();
  }

  // Hastane marker'ları oluştur
  List<Marker> createHospitalMarkers({
    required List<Hospital> hospitals,
    required Function(Hospital) onTap,
  }) {
    return hospitals.map((hospital) {
      return Marker(
        markerId: MarkerId('hospital_${hospital.id}'),
        position: LatLng(
          hospital.location.latitude,
          hospital.location.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: hospital.name,
          snippet: '${hospital.distance.toStringAsFixed(1)} km uzaklıkta',
        ),
        onTap: () => onTap(hospital),
      );
    }).toList();
  }
}
```

📌 **Adım 8.4: Rota Oluşturma ve Navigasyon Entegrasyonu**
-----------------------------------------------------
**Açıklama**
- Kullanıcıdan talep konumuna veya hastaneye rota çizimi
- Farklı ulaşım modlarına göre rota seçenekleri (araba, toplu taşıma, yürüyüş)
- Tahmini varış süresi ve mesafe bilgilerinin gösterilmesi
- Google Maps, Apple Maps gibi harici navigasyon uygulamalarına yönlendirme
- Önemli dönüş noktaları ve yönlendirme talimatları

**Rota Çizimi ve Navigasyon**
- Google Directions API entegrasyonu
- Polyline ile rota çizimi
- Rota metriklerinin gösterilmesi (uzaklık, süre)
- Navigasyon başlatma butonları
- Alternatif rotaların sunulması

📝 **Örnek Rota Oluşturma Kodu**
---------------------------
```dart
class NavigationService {
  // Google Directions API için http
  final http.Client _client = http.Client();
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  final String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // İki nokta arasında rota oluştur
  Future<Map<String, dynamic>> getRoute({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      final response = await _client.get(Uri.parse(
        '$_baseUrl?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=$travelMode'
        '&key=$_apiKey'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Rota kodlama noktaları
          List<LatLng> polylinePoints = _decodePolyline(
            data['routes'][0]['overview_polyline']['points']
          );

          // Mesafe ve süre bilgisi
          String distance = data['routes'][0]['legs'][0]['distance']['text'];
          String duration = data['routes'][0]['legs'][0]['duration']['text'];

          return {
            'polylinePoints': polylinePoints,
            'distance': distance,
            'duration': duration,
            'bounds': {
              'northeast': {
                'lat': data['routes'][0]['bounds']['northeast']['lat'],
                'lng': data['routes'][0]['bounds']['northeast']['lng'],
              },
              'southwest': {
                'lat': data['routes'][0]['bounds']['southwest']['lat'],
                'lng': data['routes'][0]['bounds']['southwest']['lng'],
              },
            },
          };
        } else {
          throw Exception(data['status']);
        }
      } else {
        throw Exception('Failed to fetch directions');
      }
    } catch (e) {
      print('Rota oluşturma hatası: $e');
      throw e;
    }
  }

  // Polyline kodlama noktalarını çözümle
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      poly.add(LatLng(latitude, longitude));
    }

    return poly;
  }

  // Harici navigasyonu başlat
  void launchMapsNavigation({
    required LatLng destination,
    String? destinationName,
    String navigationMode = 'd', // d=driving, w=walking, r=transit
  }) async {
    final params = {
      'daddr': '${destination.latitude},${destination.longitude}',
      'directionsmode': navigationMode,
    };

    if (destinationName != null) {
      params['dname'] = destinationName;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', params);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Navigasyon başlatılamadı';
    }
  }
}
```

📌 **Adım 8.5: Harita Filtre ve Etkileşim Özellikleri**
--------------------------------------------------
**Açıklama**
- Harita içeriğini çeşitli kriterlere göre filtreleme
- Kan gruplarına göre öğeleri gösterme/gizleme
- Mesafe ve bölge bazlı filtreleme
- Harita etkileşim özelliklerinin geliştirilmesi
- Harita stilleri ve görünüm seçenekleri

**Harita Filtreleri**
- Slider ile mesafe ayarı
- Kan grubu seçim paneli
- Talep türü filtreleri (acil, normal)
- Zaman aralığı seçimi
- Konum çevresi yönetimi

📝 **Örnek Filtre Sistemi**
---------------------
```dart
class BloodMapFilterScreen extends StatefulWidget {
  final void Function(BloodMapFilter) onFilterApplied;
  final BloodMapFilter currentFilter;

  const BloodMapFilterScreen({
    required this.onFilterApplied,
    required this.currentFilter,
  });

  @override
  _BloodMapFilterScreenState createState() => _BloodMapFilterScreenState();
}

class _BloodMapFilterScreenState extends State<BloodMapFilterScreen> {
  late BloodMapFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter.copy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harita Filtreleri'),
        actions: [
          TextButton(
            child: Text('SIFIRLA'),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gösterilen öğe türleri
            _buildVisibilitySection(),

            Divider(),

            // Kan grubu filtresi
            _buildBloodTypeSection(),

            Divider(),

            // Mesafe filtresi
            _buildDistanceSection(),

            Divider(),

            // Aciliyet filtresi
            _buildUrgencySection(),

            // Uygula butonu
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text('Filtreleri Uygula'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  widget.onFilterApplied(_filter);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Haritada Göster',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        CheckboxListTile(
          title: Text('Kan Talepleri'),
          value: _filter.showRequests,
          onChanged: (value) {
            setState(() => _filter.showRequests = value!);
          },
        ),
        CheckboxListTile(
          title: Text('Bağışçılar'),
          value: _filter.showDonors,
          onChanged: (value) {
            setState(() => _filter.showDonors = value!);
          },
        ),
        CheckboxListTile(
          title: Text('Hastaneler ve Kan Merkezleri'),
          value: _filter.showHospitals,
          onChanged: (value) {
            setState(() => _filter.showHospitals = value!);
          },
        ),
      ],
    );
  }

  Widget _buildBloodTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kan Grubu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: BloodType.values.map((type) {
            final isSelected = _filter.bloodTypes.contains(type);
            return FilterChip(
              label: Text(type.toString()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filter.bloodTypes.add(type);
                  } else {
                    _filter.bloodTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Arama Mesafesi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _filter.radius,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: '${_filter.radius.round()} km',
                onChanged: (value) {
                  setState(() => _filter.radius = value);
                },
              ),
            ),
            Text('${_filter.radius.round()} km'),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aciliyet Seviyesi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: UrgencyLevel.values.map((level) {
            final isSelected = _filter.urgencyLevels.contains(level);
            return FilterChip(
              label: Text(_getUrgencyText(level)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filter.urgencyLevels.add(level);
                  } else {
                    _filter.urgencyLevels.remove(level);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = BloodMapFilter.defaultFilter();
    });
  }

  String _getUrgencyText(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.veryUrgent:
        return 'Çok Acil';
      case UrgencyLevel.urgent:
        return 'Acil';
      case UrgencyLevel.normal:
        return 'Normal';
      default:
        return level.toString();
    }
  }
}

class BloodMapFilter {
  bool showRequests;
  bool showDonors;
  bool showHospitals;
  Set<BloodType> bloodTypes;
  double radius;
  Set<UrgencyLevel> urgencyLevels;

  BloodMapFilter({
    this.showRequests = true,
    this.showDonors = true,
    this.showHospitals = true,
    Set<BloodType>? bloodTypes,
    this.radius = 15.0,
    Set<UrgencyLevel>? urgencyLevels,
  }) :
    this.bloodTypes = bloodTypes ?? Set<BloodType>.from(BloodType.values),
    this.urgencyLevels = urgencyLevels ?? Set<UrgencyLevel>.from(UrgencyLevel.values);

  factory BloodMapFilter.defaultFilter() {
    return BloodMapFilter();
  }

  BloodMapFilter copy() {
    return BloodMapFilter(
      showRequests: showRequests,
      showDonors: showDonors,
      showHospitals: showHospitals,
      bloodTypes: Set<BloodType>.from(bloodTypes),
      radius: radius,
      urgencyLevels: Set<UrgencyLevel>.from(urgencyLevels),
    );
  }
}
```

📌 **Adım 8.6: Gerçek Zamanlı Konum Güncelleme ve İzleme**
----------------------------------------------------
**Açıklama**
- Kullanıcı konumunun gerçek zamanlı takibi ve güncellenmesi
- Konum değişikliklerine göre haritayı otomatik yenileme
- Arka planda çalışan konum servisi ve bildirim entegrasyonu
- Pil dostu konum izleme mekanizması
- Kullanıcı gizlilik tercihlerinin yönetimi

**Konum İzleme Özellikleri**
- Konum değişikliği dinleyicileri
- Gerçek zamanlı konum paylaşımı (opsiyonel)
- Güvenli konum verileri depolama
- Konum geçmişi yönetimi
- Bölgesel bildirimler (geofencing)

📝 **Örnek Gerçek Zamanlı Konum İzleme**
----------------------------------
```dart
class LocationTrackerService {
  // Konum değişikliğini dinleyici
  StreamSubscription<Position>? _positionStreamSubscription;

  // Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı bilgileri
  final String userId;
  bool _isLocationSharingEnabled = false;

  // Konum ayarları
  LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50, // 50 metre
  );

  LocationTrackerService({required this.userId});

  // Konum izlemeyi başlat
  Future<void> startTracking() async {
    // Kullanıcının paylaşım tercihini kontrol et
    final userDoc = await _firestore.collection('users').doc(userId).get();
    _isLocationSharingEnabled = userDoc.data()?['isLocationSharingEnabled'] ?? false;

    if (!_isLocationSharingEnabled) {
      print('Kullanıcı konum paylaşımına izin vermemiş.');
      return;
    }

    // Konum izni kontrolü
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Konum izni alınamadı.');
      return;
    }

    // Mevcut konumu al
    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Konum bilgisini güncelle
      await _updateUserLocation(initialPosition);

      // Konum değişikliği dinleyicisini başlat
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_handlePositionChange);

    } catch (e) {
      print('Konum alınamadı: $e');
    }
  }

  // Konum değişikliklerini işle
  void _handlePositionChange(Position position) async {
    if (!_isLocationSharingEnabled) return;

    try {
      // Kullanıcının konum bilgisini güncelle
      await _updateUserLocation(position);
    } catch (e) {
      print('Konum güncellenirken hata: $e');
    }
  }

  // Kullanıcı konumunu veritabanında güncelle
  Future<void> _updateUserLocation(Position position) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': GeoPoint(position.latitude, position.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      print('Konum güncellenemedi: $e');
    }
  }

  // Konum izlemeyi durdur
  void stopTracking() {
    _positionStreamSubscription?.cancel();

    // Kullanıcının çevrimiçi durumunu güncelle
    try {
      _firestore.collection('users').doc(userId).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Çevrimiçi durumu güncellenemedi: $e');
    }
  }

  // Konum paylaşım tercihini değiştir
  Future<void> setLocationSharingEnabled(bool enabled) async {
    _isLocationSharingEnabled = enabled;

    try {
      await _firestore.collection('users').doc(userId).update({
        'isLocationSharingEnabled': enabled,
      });

      if (enabled) {
        startTracking();
      } else {
        stopTracking();

        // Konum bilgisini kaldır
        await _firestore.collection('users').doc(userId).update({
          'location': null,
        });
      }
    } catch (e) {
      print('Konum paylaşım tercihi güncellenemedi: $e');
    }
  }

  // Uygulama kapatılırken çağrılmalı
  void dispose() {
    stopTracking();
  }
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Google Maps API entegrasyonu tamamlandı
- [ ] Konum erişim izinleri ve yönetimi doğru çalışıyor
- [ ] Harita üzerinde kan talepleri başarıyla gösteriliyor
- [ ] Bağışçı ve hastane konumları haritada işaretlendi
- [ ] Filtreler ve harita etkileşim özellikleri eklendi
- [ ] Rota oluşturma ve navigasyon rehberliği çalışıyor
- [ ] Harita stilleri ve görünüm seçenekleri uygulandı
- [ ] Gerçek zamanlı konum güncellemesi ve izleme tamamlandı
- [ ] Harita performansı ve yüklenme hızı optimize edildi
- [ ] Haritada gösterilen verilerin gecikmeli yüklenmesi (lazy loading) uygulandı

📌 **Onay Gereksinimleri**
----------------------
- [ ] Harita farklı cihaz boyutlarında ve yönelimlerinde doğru çalışıyor
- [ ] Harita filtreleri ve etkileşim özellikleri kullanıcı dostu
- [ ] Konum erişimi ve gizlilik tercihleri kullanıcıya açıkça sunuluyor
- [ ] Rota oluşturma ve yönlendirme sorunsuz çalışıyor
- [ ] Harita etkileşimleri akıcı ve performanslı
- [ ] Gerçek zamanlı güncellemeler pil tüketimini optimize ediyor
- [ ] Harita öğeleri görsel olarak anlaşılır ve ayrıştırılabilir

💡 **Ekstra Notlar**
----------------
- Harita yoğun bir ekran olduğundan performans optimizasyonları önemli
- Kullanıcının ilk kez konumuna erişirken açık ve anlaşılır izin istemeleri eklenebilir
- Harita üzerinde çizilen öğe sayısı arttıkça kümeleme (clustering) önemli hale gelecek
- Harita yüklenmesi sırasında iskelet yükleyici (skeleton loader) gösterilebilir
- Bazı harita özellikleri cihazın internet bağlantısına bağlı olacağından offline kullanım durumları da düşünülmeli
- Firebase Realtime Database veya Cloud Firestore gerçek zamanlı güncellemeler için değerlendirilebilir

🔄 **Ekran Tasarımları**
--------------------
1. **Ana Harita Ekranı**
   - Harita görünümü
   - Filtreleme çipleri
   - Yakınlaştırma/uzaklaştırma kontrolleri
   - Konum yenileme butonu
   - Katmanlar menüsü

2. **Filtreleme Paneli**
   - Kan grubu seçiciler
   - Mesafe ayarı sürgüsü
   - Görünürlük seçenekleri
   - Aciliyet filtreleri
   - Uygula/Sıfırla butonları

3. **Detay Kartları**
   - Talep detay kartı
   - Bağışçı profil kartı
   - Hastane bilgi kartı
   - Hızlı eylem butonları

4. **Navigasyon ve Rota Ekranı**
   - Rota çizimi
   - Mesafe ve süre bilgisi
   - Ulaşım modu seçenekleri
   - Yönlendirme talimatları

🚀 **Faz 8 Çıktıları**
------------------
✅ Tam işlevsel konum tabanlı harita sistemi
✅ Kan talebi, bağışçı ve hastane görselleştirme
✅ Filtreleme ve etkileşim özellikleri
✅ Rota oluşturma ve navigasyon yönlendirmesi
✅ Gerçek zamanlı konum izleme ve güncelleme

🔄 **Sonraki Adım: Çağrıya Yanıt Verme**
----------------------------------
Bir sonraki fazda (Faz 9), kullanıcıların kan taleplerine yanıt verme süreci ele alınacak:
- Talep bildirimlerine yanıt verme
- Talep sahibiyle iletişim kurma
- Randevu oluşturma ve onay mekanizması
- Bağış sürecinin takibi
- Çağrı sonuçlandırma ve geri bildirim
