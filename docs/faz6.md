🚀 KanBul – Faz 6: Bağışçı Paneli
==========================

🎯 **Hedefler**
--------------
- Bağışçı rolü için özelleştirilmiş ana ekran ve kullanıcı deneyimi oluşturulması
- Gönüllü kan bağışçılarını teşvik edecek özellikler ve gamifikasyon elementlerinin eklenmesi
- Bağış geçmişi ve planlama özelliklerinin geliştirilmesi
- Acil kan ihtiyaçlarına hızlı yanıt verme mekanizmasının tasarlanması
- Bağışçı profilinin zenginleştirilmesi ve yönetimi

📌 **Adım 6.1: Bağışçı Ana Ekranının (Dashboard) Tasarlanması**
-----------------------------------------------------------
**Açıklama**
- Bağışçılar için özelleştirilmiş ana ekranın tasarlanması
- Yakındaki acil kan talepleri ve kritik ihtiyaçların görüntülenmesi
- Bir sonraki uygun bağış tarihi ve öneriler
- Kan bağışı istatistikleri ve bağış etkisinin gösterilmesi
- Güncel kan ihtiyacı trendleri

**UI Bileşenleri**
- Bağışçı durumu özeti kartı (Ne zaman tekrar bağış yapabilir, kan grubu, vb.)
- Yakındaki acil kan talepleri listesi/haritası
- Kan bağışı etki göstergeleri (kaç kişiye yardım edildiği, vb.)
- Bağış geçmişi özeti
- Yaklaşan randevular
- Hızlı eylem butonları

📌 **Adım 6.2: Bağış Geçmişi ve Takvim Özelliği**
---------------------------------------------
**Açıklama**
- Geçmiş kan bağışlarının detaylı kaydının tutulması
- Bir sonraki bağış için uygun tarihin hesaplanması ve hatırlatması
- Bağış randevuları için takvim entegrasyonu
- Bağış yerlerinin (hastane, kan merkezi) kayıt ve öneri sistemi
- Düzenli bağış için hatırlatıcı ayarları

**Temel Fonksiyonlar**
- Bağış geçmişini görüntüleme ve filtreleme
- Yeni randevu oluşturma ve takvime ekleme
- Randevu hatırlatmaları ve bildirimler
- Bağış sıklığı ve zaman aralığı kontrolü
- Favori bağış merkezleri yönetimi

📝 **Örnek Bağış Geçmişi Modeli**
----------------------------
```dart
class DonationRecord {
  final String id;
  final DateTime donationDate;
  final String donationCenter;
  final BloodDonationType type; // Tam kan, trombosit, vb.
  final DonationStatus status; // Tamamlandı, İptal, Planlandı
  final String? recipientRequestId; // İlişkili talep varsa
  final String? notes;

  const DonationRecord({
    required this.id,
    required this.donationDate,
    required this.donationCenter,
    required this.type,
    required this.status,
    this.recipientRequestId,
    this.notes,
  });

  // Bir sonraki bağış tarihini hesapla (kan tipine göre)
  DateTime calculateNextEligibleDate() {
    switch (type) {
      case BloodDonationType.wholeBlood:
        return donationDate.add(Duration(days: 90)); // 3 ay
      case BloodDonationType.platelets:
        return donationDate.add(Duration(days: 14)); // 2 hafta
      case BloodDonationType.plasma:
        return donationDate.add(Duration(days: 28)); // 4 hafta
      default:
        return donationDate.add(Duration(days: 90));
    }
  }

  // Firestore serializasyon metodları...
}
```

📌 **Adım 6.3: Puan ve Rozet Sistemi**
----------------------------------
**Açıklama**
- Bağışçıları teşvik etmek için gamifikasyon sisteminin kurulması
- Bağış sayısı ve düzenliliğine göre rozet ve seviye sistemi
- Bağışlardan kazanılan puanların takibi ve gösterilmesi
- Bağışçı sıralamaları ve liderlik tabloları
- Özel başarılar ve kilometre taşlarının kutlanması

**Rozet Türleri**
- İlk Bağış Rozeti
- Düzenli Bağışçı (ardışık bağışlar)
- Hayat Kurtaran (acil taleplere yanıt)
- Platin/Altın/Gümüş Bağışçı (bağış sayısına göre)
- Özel Etkinlik/Kampanya Rozetleri
- Yıldönümü Rozetleri

📝 **Örnek Gamifikasyon Yapısı**
---------------------------
```dart
class DonorGamification {
  final String donorId;
  final int totalPoints;
  final int donationCount;
  final int emergencyResponseCount;
  final DonorLevel level;
  final List<DonorBadge> badges;
  final int rank; // İsteğe bağlı, sıralama

  const DonorGamification({
    required this.donorId,
    required this.totalPoints,
    required this.donationCount,
    required this.emergencyResponseCount,
    required this.level,
    required this.badges,
    this.rank,
  });

  // Yeni bağış eklendikten sonra puan hesaplama
  static int calculatePointsForDonation(DonationRecord donation) {
    int basePoints = 100;

    // Acil talepler için bonus
    if (donation.recipientRequestId != null) {
      basePoints += 50;
    }

    // Bağış tipine göre ek puanlar
    switch (donation.type) {
      case BloodDonationType.wholeBlood:
        basePoints += 100;
        break;
      case BloodDonationType.platelets:
        basePoints += 150;
        break;
      case BloodDonationType.plasma:
        basePoints += 120;
        break;
    }

    return basePoints;
  }

  // Seviye kontrolü ve yükseltme
  DonorLevel checkForLevelUp() {
    if (donationCount >= 50) return DonorLevel.platinum;
    if (donationCount >= 25) return DonorLevel.gold;
    if (donationCount >= 10) return DonorLevel.silver;
    if (donationCount >= 5) return DonorLevel.bronze;
    return DonorLevel.starter;
  }

  // Yeni rozet kazanma durumu kontrolü
  List<DonorBadge> checkForNewBadges() {
    // Rozet kontrol mantığı...
    // ...

    return earnedBadges;
  }
}
```

📌 **Adım 6.4: Yakındaki Kan Talepleri Haritası**
--------------------------------------------
**Açıklama**
- Bağışçının konumuna göre yakındaki acil kan taleplerinin gösterilmesi
- Harita üzerinde kan talep eden hastane ve merkezlerin işaretlenmesi
- Mesafe ve kan grubu uyumuna göre filtreleme
- Talebe yanıt verme ve yönlendirme sürecinin tasarlanması
- Rota ve navigasyon desteği

**Google Maps Entegrasyonu**
- Kullanıcı konumunun tespiti ve haritada gösterilmesi
- Kan talep noktalarını işaretleme ve gruplama
- Kan talebi detaylarının bilgi penceresi (info window)
- Mesafe ve süre hesaplaması
- Rota oluşturma ve yönlendirme

📝 **Örnek Harita Entegrasyonu**
---------------------------
```dart
class NearbyRequestsMap extends StatefulWidget {
  final BloodType userBloodType;

  const NearbyRequestsMap({required this.userBloodType});

  @override
  _NearbyRequestsMapState createState() => _NearbyRequestsMapState();
}

class _NearbyRequestsMapState extends State<NearbyRequestsMap> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  // Kullanıcının konumu
  LatLng? _currentPosition;

  // Kan talepleri
  List<BloodRequest> _nearbyRequests = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadNearbyBloodRequests();
  }

  // Güncel konumu al
  Future<void> _getCurrentLocation() async {
    // Konum servisi ile konumu al
    // ...

    // Haritayı konuma merkezle
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    }
  }

  // Yakındaki talepleri yükle
  Future<void> _loadNearbyBloodRequests() async {
    if (_currentPosition == null) return;

    // Firestore'dan yakındaki talepleri sorgula (GeoFirestore)
    // ...

    // Kan grubu uyumluluğuna göre filtrele
    _nearbyRequests = _nearbyRequests
        .where((request) => isBloodTypeCompatible(widget.userBloodType, request.bloodType))
        .toList();

    // Haritaya işaretleyicileri ekle
    _addMarkersToMap();
  }

  // İşaretleyicileri haritaya ekle
  void _addMarkersToMap() {
    for (final request in _nearbyRequests) {
      final marker = Marker(
        markerId: MarkerId(request.id),
        position: LatLng(request.location.latitude, request.location.longitude),
        infoWindow: InfoWindow(
          title: '${request.bloodType} Kan İhtiyacı',
          snippet: '${request.hospitalName} - ${request.urgencyLevel.toString()}',
        ),
        onTap: () => _showRequestDetails(request),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  // Talep detaylarını göster
  void _showRequestDetails(BloodRequest request) {
    // Detay modalı veya sayfası göster
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yakındaki Kan İhtiyaçları')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition ?? LatLng(41.0082, 28.9784), // Varsayılan Istanbul
          zoom: 14,
        ),
        markers: _markers,
        circles: _circles,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _refreshNearbyRequests(),
        label: Text('Yenile'),
        icon: Icon(Icons.refresh),
      ),
    );
  }
}
```

📌 **Adım 6.5: Bağışçı Profil Yönetimi**
------------------------------------
**Açıklama**
- Bağışçı için detaylı profil bilgilerinin düzenlenmesi
- Sağlık geçmişi ve uygunluk durumu bilgilerinin yönetimi
- Bildirim ve hatırlatma tercihlerinin ayarlanması
- Gizlilik ve konum izni ayarları
- Dijital bağışçı kartı ve kimlik özelliği

**Profil Bileşenleri**
- Kişisel bilgiler (ad, iletişim, fotoğraf)
- Kan grubu ve bağış geçmişi
- Sağlık durumu ve bağışa uygunluk bilgileri
- Bildirim tercihleri
- Konum erişimi ayarları
- Acil durum kişileri
- Bağışçı kimlik kartı

📝 **Örnek Profil Yönetim UI**
-------------------------
```dart
class DonorProfileScreen extends StatefulWidget {
  final String donorId;

  const DonorProfileScreen({required this.donorId});

  @override
  _DonorProfileScreenState createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  late DonorProfile _donorProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonorProfile();
  }

  Future<void> _loadDonorProfile() async {
    // Firestore'dan bağışçı profilini yükle
    // ...

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bağışçı Profilim'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToProfileEdit(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil başlık bölümü
            _buildProfileHeader(),

            // Kan bağışı bilgileri
            _buildDonationInfo(),

            // Kazanılan rozetler
            _buildBadgesSection(),

            // Dijital bağışçı kartı
            _buildDigitalDonorCard(),

            // Ayarlar bölümleri
            _buildNotificationSettings(),
            _buildLocationSettings(),
            _buildPrivacySettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      // Profil başlık içeriği...
    );
  }

  // Diğer UI bölümleri...
}
```

📌 **Adım 6.6: Kan Talebi Yanıt Mekanizması**
----------------------------------------
**Açıklama**
- Bağışçının kan taleplerine yanıt verme sürecinin tasarlanması
- Talepleri filtreleme ve uygun talepleri görüntüleme
- Yanıt sonrası randevu ve koordinasyon süreci
- Talep sahibi ile iletişim seçenekleri
- Bağış tamamlandıktan sonra doğrulama ve takip süreci

**Süreç Akışı**
1. Bağışçı uygun bir kan talebi görür
2. Talebe yanıt vermeyi seçer
3. Randevu tarihi/saati seçilir
4. Talep sahibine bildirim gönderilir
5. Randevu onaylandıktan sonra takvime eklenir
6. Bağış tamamlandığında doğrulama yapılır
7. Puan ve rozetler güncellenir

📝 **Örnek Yanıt Süreci**
--------------------
```dart
class BloodRequestResponseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Talebe yanıt ver
  Future<void> respondToBloodRequest({
    required String donorId,
    required String requestId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    // Yanıt dokümanı oluştur
    final response = DonationResponse(
      id: Uuid().v4(),
      donorId: donorId,
      requestId: requestId,
      responseDate: DateTime.now(),
      status: ResponseStatus.pending,
      appointmentDate: appointmentDate,
      notes: notes,
    );

    // Firestore'a kaydet
    await _firestore
      .collection('blood_requests')
      .doc(requestId)
      .collection('responses')
      .doc(response.id)
      .set(response.toMap());

    // Talep durumunu güncelle
    await _firestore
      .collection('blood_requests')
      .doc(requestId)
      .update({'responseCount': FieldValue.increment(1)});

    // Talep sahibine bildirim gönder
    await _sendNotificationToRequestOwner(requestId, donorId);

    // Bağışçının takvim/geçmişine planlanan bağışı ekle
    await _addToDonorSchedule(donorId, requestId, appointmentDate);
  }

  // Diğer yardımcı metodlar...
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Bağışçı ana ekranı tasarlandı ve gerekli bileşenler eklendi
- [ ] Bağış geçmişi ve takvim özelliği entegre edildi
- [ ] Puan ve rozet sistemi uygulandı
- [ ] Kan talepleri haritası ve lokasyon bazlı özellikler çalışıyor
- [ ] Bağışçı profil yönetimi ekranları tamamlandı
- [ ] Kan talebi yanıt mekanizması çalışır durumda
- [ ] Bildirim ve hatırlatmalar entegre edildi
- [ ] Gamifikasyon elementleri test edildi ve doğru çalışıyor
- [ ] Tüm veritabanı bağlantıları uygun şekilde yapılandırıldı
- [ ] Kullanıcı deneyimi tasarım kılavuzuna uygun

📌 **Onay Gereksinimleri**
----------------------
- [ ] Bağışçı paneli kullanıcı deneyimi akıcı ve sezgisel
- [ ] Bağış geçmişi ve takvim doğru çalışıyor
- [ ] Kan taleplerini haritada görüntüleme işlevi hatasız
- [ ] Puan ve rozet sistemi kullanıcıları teşvik edecek şekilde çalışıyor
- [ ] Bildirim ve hatırlatmalar doğru zamanda gönderiliyor
- [ ] Tüm ekranlar duyarlı (responsive) ve farklı cihazlarda uyumlu
- [ ] Veri tutarlılığı tüm süreçlerde sağlanıyor

💡 **Ekstra Notlar**
----------------
- Bağışçı profilinde sağlık geçmişi ve uygunluk durumu düzenli güncellenmeli
- Kan bağışı sonrası sağlık önerileri ve bilgilendirmeler eklenebilir
- Sosyal medyada bağış başarılarını paylaşma özelliği düşünülebilir
- Yakındaki kan bağış merkezleri ve çalışma saatleri bilgisi eklenebilir
- Acil durum mesajlaşma sistemi uygulanabilir
- Gönüllü bağışçı topluluğu ve forum özelliği ileride eklenebilir

🔄 **Ekran Tasarımları**
--------------------
1. **Bağışçı Ana Ekranı (Dashboard)**
   - Kullanıcı durumu özet kartı
   - Yakın bağış merkezleri
   - Yakındaki acil talepler
   - Kazanılan rozetler ve seviye
   - Son bağış bilgisi

2. **Bağış Geçmişi ve Takvim**
   - Takvim görünümü
   - Geçmiş bağışlar listesi
   - Filtreleme seçenekleri
   - Randevu oluşturma formu

3. **Rozetler ve Başarılar**
   - Rozet koleksiyonu
   - İlerleme çubukları
   - Bir sonraki hedef
   - Sıralama ve istatistikler

4. **Kan Talepleri Haritası**
   - İnteraktif harita görünümü
   - Filtre seçenekleri
   - Talep detay kartları
   - Rota ve yönlendirme

5. **Bağışçı Profil Ekranı**
   - Profil düzenleme formu
   - Sağlık bilgileri
   - Dijital bağışçı kartı
   - Bildirim ve ayarlar

🚀 **Faz 6 Çıktıları**
------------------
✅ Tam işlevsel bağışçı paneli
✅ Gelişmiş bağışçı profil yönetimi
✅ Bağış takip ve takvim sistemi
✅ Gamifikasyon (rozet ve puan) sistemi
✅ Konum bazlı kan talebi eşleştirme

🔄 **Sonraki Adım: Kan Talebi Oluşturma**
------------------------------------
Bir sonraki fazda (Faz 7), hasta yakınları ve hastanelerin kan talebi oluşturma süreçleri ele alınacak:
- Kan talebi oluşturma formu
- Talep durumu takibi
- Yanıtların yönetimi
- Talep ayarları ve bildirimleri
- Talep sonuçlandırma süreci
