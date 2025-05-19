🚀 KanBul – Faz 7: Kan Talebi Oluşturma
==========================

🎯 **Hedefler**
--------------
- Hasta yakını ve hastane kullanıcı rolleri için kan talebi oluşturma sürecinin tasarlanması
- Kan ihtiyacı durumlarında hızlı ve etkili talep oluşturma formlarının geliştirilmesi
- Talep durumunun takibi ve yönetimi için araçların oluşturulması
- Kan taleplerine gelen yanıtların verimli şekilde yönetilmesi
- Taleplerin sonuçlandırılması ve istatistiklerin tutulması
- Acil durumlar için öncelik sistemi ve hızlı yönlendirme mekanizması

📌 **Adım 7.1: Kan Talebi Oluşturma Formlarının Tasarlanması**
----------------------------------------------------------
**Açıklama**
- Hasta yakını ve hastane rolleri için özelleştirilmiş talep formlarının tasarlanması
- Kullanıcı dostu ve hızlı talep oluşturma arayüzü
- Gerekli bilgilerin adım adım toplanması
- Konum seçimi ve hastane bilgilerinin entegrasyonu
- Acil durum seviyesi belirleme mekanizması

**Hasta Yakını Talep Formu Bileşenleri**
- Hasta bilgileri (ad, yaş, cinsiyet)
- Kan grubu seçimi
- Gerekli ünite miktarı
- Hastane/sağlık kuruluşu bilgileri (lokasyon, iletişim)
- Talep aciliyet seviyesi
- Son tarih belirtme
- Ek açıklama/notlar
- İletişim tercihleri

**Hastane Talep Formu Ek Bileşenleri**
- Toplu kan talebi seçeneği (birden fazla kan grubu)
- Departman bilgisi
- Yetkili personel bilgisi
- Dahili referans numarası
- Tıbbi prosedür kategorisi
- Periyodik talep oluşturma seçeneği

📝 **Örnek Talep Modeli**
--------------------
```dart
class BloodRequest {
  final String id;
  final String requesterId; // Talep sahibinin ID'si
  final UserRole requesterType; // Hasta yakını veya hastane
  final DateTime creationDate;
  final BloodType bloodType;
  final int unitsNeeded;
  final UrgencyLevel urgencyLevel; // Normal, Acil, Çok Acil
  final DateTime requiredByDate; // İhtiyaç son tarihi
  final GeoPoint location;
  final String hospitalName;
  final String? hospitalDepartment; // Hastane için
  final String patientInfo; // Hasta yakını için
  final String notes;
  final RequestStatus status; // Aktif, Karşılandı, İptal
  final int responseCount; // Gelen yanıt sayısı
  final List<String> fulfillmentDonorIds; // Yanıt veren bağışçılar

  const BloodRequest({
    required this.id,
    required this.requesterId,
    required this.requesterType,
    required this.creationDate,
    required this.bloodType,
    required this.unitsNeeded,
    required this.urgencyLevel,
    required this.requiredByDate,
    required this.location,
    required this.hospitalName,
    this.hospitalDepartment,
    required this.patientInfo,
    required this.notes,
    required this.status,
    this.responseCount = 0,
    this.fulfillmentDonorIds = const [],
  });

  // Firestore serializasyon metodları...

  // Kalan ünite ihtiyacı hesaplama
  int get remainingUnitsNeeded => unitsNeeded - fulfillmentDonorIds.length;

  // Talep karşılandı mı kontrolü
  bool get isFulfilled => remainingUnitsNeeded <= 0;

  // Aciliyet durumuna göre sınıflandırma
  bool get isUrgent => urgencyLevel == UrgencyLevel.urgent ||
                      urgencyLevel == UrgencyLevel.veryUrgent;

  // Geçerlilik kontrolü
  bool get isValid => requiredByDate.isAfter(DateTime.now());
}
```

📌 **Adım 7.2: Hasta Yakını için Talep Oluşturma Süreçleri**
--------------------------------------------------------
**Açıklama**
- Hasta yakınlarının kan talebi oluşturma yolculuğunun tasarlanması
- Form doğrulama ve hata yönetimi
- Konuma dayalı bağışçı eşleştirmesi için veri formatı
- Talep görünürlük ayarları (yakın çevreye özel, herkese açık)
- Talep paylaşım seçenekleri (sosyal medya, direkt mesaj)

**UI Akışı**
1. Ana ekrandan kan talebi oluştur butonuna tıklama
2. Hasta bilgileri formu doldurma
3. Kan grubu ve miktar belirleme
4. Hastane/lokasyon bilgileri girme (harita entegrasyonlu)
5. Aciliyet seviyesi seçme
6. Özet ekranı ve onay
7. Talep oluşturuldu onayı ve paylaşım seçenekleri

📝 **Örnek Hasta Yakını Talep Oluşturma**
-----------------------------------
```dart
class PatientRelativeRequestScreen extends StatefulWidget {
  @override
  _PatientRelativeRequestScreenState createState() => _PatientRelativeRequestScreenState();
}

class _PatientRelativeRequestScreenState extends State<PatientRelativeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final BloodRequestFormData _formData = BloodRequestFormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kan Talebi Oluştur'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        steps: [
          // Adım 1: Hasta Bilgileri
          Step(
            title: Text('Hasta Bilgileri'),
            content: _buildPatientInfoForm(),
            isActive: _currentStep >= 0,
          ),

          // Adım 2: Kan Detayları
          Step(
            title: Text('Kan Bilgileri'),
            content: _buildBloodDetailsForm(),
            isActive: _currentStep >= 1,
          ),

          // Adım 3: Hastane Bilgileri
          Step(
            title: Text('Hastane Bilgileri'),
            content: _buildHospitalInfoForm(),
            isActive: _currentStep >= 2,
          ),

          // Adım 4: İletişim ve Paylaşım
          Step(
            title: Text('İletişim Tercihleri'),
            content: _buildContactPreferencesForm(),
            isActive: _currentStep >= 3,
          ),

          // Adım 5: Özet ve Onay
          Step(
            title: Text('Özet ve Onay'),
            content: _buildSummaryView(),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoForm() {
    // Hasta adı, yaşı, cinsiyeti gibi bilgileri toplayan form
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Hasta Adı Soyadı'),
          validator: (value) => value!.isEmpty ? 'Hasta adı gereklidir' : null,
          onSaved: (value) => _formData.patientName = value!,
        ),
        // Diğer form alanları...
      ],
    );
  }

  // Diğer form bileşenleri...

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep += 1);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Form verilerinden talep nesnesi oluştur
        final bloodRequest = _createBloodRequest();

        // Firebase'e talep oluştur
        final requestId = await BloodRequestService().createBloodRequest(bloodRequest);

        // Başarılı oluşturma sonrası
        _showSuccessAndShare(requestId);
      } catch (e) {
        // Hata durumu işleme
        _showErrorDialog(e.toString());
      }
    }
  }

  BloodRequest _createBloodRequest() {
    // Form verilerinden talep nesnesi oluştur
    // ...

    return bloodRequest;
  }

  void _showSuccessAndShare(String requestId) {
    // Başarı mesajı ve paylaşım seçenekleri
    // ...
  }
}
```

📌 **Adım 7.3: Hastane için Toplu Talep Oluşturma**
-----------------------------------------------
**Açıklama**
- Hastanelerin birden fazla kan grubu/ürünü için toplu talep oluşturması
- Hastane içi yetkilendirme ve onay mekanizması
- Periyodik ve tekrarlayan talep seçenekleri
- Öncelik ve önemlilik düzeyi belirleme
- Bağışçılara özel bilgilendirme ve talimatlar

**Toplu Talep Formunun Bileşenleri**
- Birden fazla kan grubu seçimi ve ünite miktarları
- Departman ve prosedür bilgisi
- Yetkili personel atama
- Zaman çizelgesi oluşturma
- Bağışçılar için özel talimatlar (aç/tok gelme, ilaç kısıtlamaları vb.)
- Periyodik talep ayarları

📝 **Örnek Hastane Talep Yapısı**
---------------------------
```dart
class HospitalBulkRequestScreen extends StatefulWidget {
  @override
  _HospitalBulkRequestScreenState createState() => _HospitalBulkRequestScreenState();
}

class _HospitalBulkRequestScreenState extends State<HospitalBulkRequestScreen> {
  final List<BloodTypeRequest> _bloodTypeRequests = [];
  final HospitalRequestData _requestData = HospitalRequestData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toplu Kan Talebi')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hastane departman seçimi
              _buildDepartmentSelector(),

              // Yetkili personel bilgisi
              _buildAuthorizedPersonnelInfo(),

              // Kan grubu talepleri listesi
              _buildBloodTypeRequestsList(),

              // Yeni kan grubu talebi ekleme butonu
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Kan Grubu Ekle'),
                onPressed: _addBloodTypeRequest,
              ),

              SizedBox(height: 20),

              // Periyodik talep ayarları
              _buildPeriodicRequestSection(),

              // Talimatlar ve notlar
              _buildInstructionsSection(),

              // Talep oluşturma butonu
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Toplu Kan Talebini Oluştur'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: _submitBulkRequest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kan grubu talebi ekleme
  void _addBloodTypeRequest() {
    setState(() {
      _bloodTypeRequests.add(BloodTypeRequest(
        bloodType: BloodType.aPositive,
        unitsNeeded: 1,
      ));
    });
  }

  // Toplu talep oluşturma
  Future<void> _submitBulkRequest() async {
    // Validasyon
    if (_bloodTypeRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('En az bir kan grubu talebi ekleyin')),
      );
      return;
    }

    // Her kan grubu için ayrı talep oluştur ve bir grup ID altında ilişkilendir
    final String bulkRequestId = Uuid().v4();

    try {
      final bloodRequests = _bloodTypeRequests.map((typeRequest) {
        return BloodRequest(
          id: Uuid().v4(),
          requesterId: currentUser.id,
          requesterType: UserRole.hospital,
          creationDate: DateTime.now(),
          bloodType: typeRequest.bloodType,
          unitsNeeded: typeRequest.unitsNeeded,
          urgencyLevel: _requestData.urgencyLevel,
          requiredByDate: _requestData.requiredByDate,
          location: _requestData.location,
          hospitalName: currentUser.hospitalName,
          hospitalDepartment: _requestData.department,
          patientInfo: '',
          notes: _requestData.instructions,
          status: RequestStatus.active,
          bulkRequestId: bulkRequestId, // Toplu talep ID'si
        );
      }).toList();

      // Talepleri Firestore'a yükle
      await BloodRequestService().createBulkRequest(bloodRequests);

      // Başarı mesajı ve yönlendirme
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BulkRequestSuccessScreen(bulkRequestId: bulkRequestId),
        ),
      );
    } catch (e) {
      // Hata işleme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep oluşturulurken bir hata oluştu: ${e.toString()}')),
      );
    }
  }

  // UI bileşenleri...
}
```

📌 **Adım 7.4: Talep Durumu Takibi ve Kontrol Paneli**
-------------------------------------------------
**Açıklama**
- Aktif taleplerin durumunu izleme ve yönetme arayüzünün tasarlanması
- Taleplere gelen yanıtların görüntülenmesi ve değerlendirilmesi
- Talep güncelleme ve düzenleme işlevleri
- Talep iptal ve sonlandırma süreçleri
- İstatistikler ve görselleştirme araçları

**Gösterge Paneli (Dashboard) Bileşenleri**
- Aktif talepler özet kartları
- Yanıt bekleyen ve onaylanan bağışçı sayıları
- Kalan ünite miktarları ve karşılanma oranları
- Talep zaman çizelgesi
- Talep kalan süre göstergeleri
- Harita üzerinde talep ve yanıt konumları

📝 **Örnek Talep Yönetim Sayfası**
----------------------------
```dart
class RequestManagementScreen extends StatefulWidget {
  @override
  _RequestManagementScreenState createState() => _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodRequest> _activeRequests = [];
  List<BloodRequest> _completedRequests = [];
  List<BloodRequest> _expiredRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      // Kullanıcının oluşturduğu talepleri yükle
      final currentUser = AuthService().currentUser;
      final requestService = BloodRequestService();

      final requests = await requestService.getRequestsByRequesterId(currentUser.uid);

      // Talepleri durumlarına göre ayır
      setState(() {
        _activeRequests = requests.where((r) => r.status == RequestStatus.active && r.isValid).toList();
        _completedRequests = requests.where((r) => r.status == RequestStatus.fulfilled).toList();
        _expiredRequests = requests.where((r) =>
          r.status == RequestStatus.active && !r.isValid ||
          r.status == RequestStatus.cancelled
        ).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Talepler yüklenirken bir hata oluştu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taleplerim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Aktif (${_activeRequests.length})'),
            Tab(text: 'Tamamlanan (${_completedRequests.length})'),
            Tab(text: 'Süresi Geçen (${_expiredRequests.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(_activeRequests, isActive: true),
                _buildRequestsList(_completedRequests),
                _buildRequestsList(_expiredRequests),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToCreateRequest(),
      ),
    );
  }

  Widget _buildRequestsList(List<BloodRequest> requests, {bool isActive = false}) {
    if (requests.isEmpty) {
      return Center(child: Text('Bu kategoride talep bulunmuyor.'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return RequestCard(
          request: request,
          onTap: () => _navigateToRequestDetail(request),
          onEdit: isActive ? () => _editRequest(request) : null,
          onCancel: isActive ? () => _cancelRequest(request) : null,
        );
      },
    );
  }

  // Navigasyon ve işlem metodları...
}
```

📌 **Adım 7.5: Talep Yanıtlarının Yönetimi**
---------------------------------------
**Açıklama**
- Taleplere gelen bağışçı yanıtlarının görüntülenmesi ve yönetilmesi
- Bağışçı profillerini inceleme ve seçme araçları
- Randevu oluşturma ve onaylama süreci
- Bağışçılarla iletişim mekanizmaları
- Tamamlanan bağışların doğrulama süreci

**Yanıt Yönetim Bileşenleri**
- Yanıt veren bağışçılar listesi
- Bağışçı profil görüntüleme
- Bağış geçmişi ve rozetleri inceleme
- Randevu tarih/saat seçimi
- Mesajlaşma arayüzü
- Bağış tamamlama onayı

📝 **Örnek Yanıt Yönetim Sayfası**
----------------------------
```dart
class RequestResponsesScreen extends StatefulWidget {
  final String requestId;

  const RequestResponsesScreen({required this.requestId});

  @override
  _RequestResponsesScreenState createState() => _RequestResponsesScreenState();
}

class _RequestResponsesScreenState extends State<RequestResponsesScreen> {
  late BloodRequest _request;
  List<DonationResponse> _pendingResponses = [];
  List<DonationResponse> _approvedResponses = [];
  List<DonationResponse> _completedResponses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequestAndResponses();
  }

  Future<void> _loadRequestAndResponses() async {
    setState(() => _isLoading = true);

    try {
      // Talebi ve yanıtları yükle
      final requestService = BloodRequestService();
      _request = await requestService.getRequestById(widget.requestId);

      final responses = await requestService.getResponsesForRequest(widget.requestId);

      setState(() {
        // Yanıtları durumlarına göre ayır
        _pendingResponses = responses.where((r) => r.status == ResponseStatus.pending).toList();
        _approvedResponses = responses.where((r) => r.status == ResponseStatus.approved).toList();
        _completedResponses = responses.where((r) => r.status == ResponseStatus.completed).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Yanıtlar yüklenirken bir hata oluştu');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Talep Yanıtları')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Talep Yanıtları'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showRequestDetails(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Talep özeti
          _buildRequestSummary(),

          // Yanıt kategorileri
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Bekleyen (${_pendingResponses.length})'),
                      Tab(text: 'Onaylı (${_approvedResponses.length})'),
                      Tab(text: 'Tamamlanan (${_completedResponses.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildResponsesList(_pendingResponses, ResponseStatus.pending),
                        _buildResponsesList(_approvedResponses, ResponseStatus.approved),
                        _buildResponsesList(_completedResponses, ResponseStatus.completed),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummary() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_request.bloodType} Kan Talebi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('İhtiyaç: ${_request.unitsNeeded} ünite'),
            Text('Karşılanan: ${_request.fulfillmentDonorIds.length} ünite'),
            LinearProgressIndicator(
              value: _request.fulfillmentDonorIds.length / _request.unitsNeeded,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _request.isFulfilled ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesList(List<DonationResponse> responses, ResponseStatus status) {
    if (responses.isEmpty) {
      return Center(child: Text('Bu kategoride yanıt bulunmuyor.'));
    }

    return ListView.builder(
      itemCount: responses.length,
      itemBuilder: (context, index) {
        final response = responses[index];
        return DonorResponseCard(
          response: response,
          onViewProfile: () => _viewDonorProfile(response.donorId),
          onApprove: status == ResponseStatus.pending
              ? () => _approveResponse(response)
              : null,
          onComplete: status == ResponseStatus.approved
              ? () => _markAsCompleted(response)
              : null,
          onMessage: () => _messageWithDonor(response.donorId),
        );
      },
    );
  }

  // İşlem ve navigasyon metodları...
}
```

📌 **Adım 7.6: Talep Bildirim ve Yönlendirme Sistemi**
-------------------------------------------------
**Açıklama**
- Kan talebi oluşturulduğunda uygun bağışçıları bilgilendirme mekanizması
- Aciliyet bazlı bildirim stratejileri
- Çevredeki bağışçıları konuma göre filtreleme ve bilgilendirme
- Sosyal medya ve diğer platformlarda talep paylaşımı
- Kan talebinin görünürlüğünü artıracak öneri mekanizması

**Bildirim Stratejisi**
- Yakındaki uygun kan grubuna sahip bağışçılara push bildirimleri
- Acil durumlarda daha geniş alandaki bağışçılara bildirim
- Belirli bir süre yanıt alınmazsa bildirim yineleme
- Kan grubu uyumluluğuna göre bildirim filtreleme
- Sosyal medya paylaşım mekanizması

📝 **Örnek Bildirim Servisi**
-----------------------
```dart
class BloodRequestNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Yeni kan talebi için bildirim gönder
  Future<void> notifyDonorsForNewRequest(BloodRequest request) async {
    try {
      // Uygun kan gruplarını belirle (alıcı/donör uyumluluğu)
      List<BloodType> compatibleTypes = getCompatibleBloodTypes(request.bloodType);

      // Maksimum mesafe belirle (aciliyete göre)
      double maxDistance = _determineSearchRadiusByUrgency(request.urgencyLevel);

      // Yakındaki uygun bağışçıları bul (GeoFirestore)
      List<String> nearbyDonorIds = await _findNearbyDonorsWithBloodTypes(
        location: request.location,
        bloodTypes: compatibleTypes,
        maxDistanceKm: maxDistance
      );

      if (nearbyDonorIds.isEmpty) {
        return;
      }

      // Bildirim verileri
      final notificationData = {
        'type': 'blood_request',
        'requestId': request.id,
        'bloodType': request.bloodType.toString(),
        'urgencyLevel': request.urgencyLevel.toString(),
        'hospitalName': request.hospitalName,
        'location': {
          'latitude': request.location.latitude,
          'longitude': request.location.longitude,
        },
      };

      // FCM topic oluştur
      final topic = 'blood_request_${request.id}';

      // Bildirimi gönder
      await _sendNotificationToDonors(
        donorIds: nearbyDonorIds,
        title: '${request.bloodType} Kan İhtiyacı',
        body: '${request.hospitalName} hastanesinde acil ${request.bloodType} kan ihtiyacı var.',
        data: notificationData,
        topic: topic,
      );

      // İstatistik güncelle
      await _firestore
          .collection('blood_requests')
          .doc(request.id)
          .update({
            'notifiedDonorCount': nearbyDonorIds.length,
            'notificationTopic': topic,
          });
    } catch (e) {
      print('Bildirim gönderilirken hata: $e');
    }
  }

  // Mesafeyi aciliyete göre belirle
  double _determineSearchRadiusByUrgency(UrgencyLevel urgencyLevel) {
    switch (urgencyLevel) {
      case UrgencyLevel.veryUrgent:
        return 50.0; // 50 km
      case UrgencyLevel.urgent:
        return 30.0; // 30 km
      case UrgencyLevel.normal:
      default:
        return 15.0; // 15 km
    }
  }

  // Uygun kan grupları listesi
  List<BloodType> getCompatibleBloodTypes(BloodType recipientType) {
    // Kan grubu uyumluluk mantığı
    // ...

    return compatibleTypes;
  }

  // Diğer yardımcı metodlar...
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Hasta yakını ve hastane rolleri için kan talebi formları tasarlandı
- [ ] Form doğrulama ve hata işleme entegre edildi
- [ ] Hastane için toplu talep oluşturma işlevi eklendi
- [ ] Konum bazlı talep oluşturma ve gösterimi entegre edildi
- [ ] Aciliyet seviyeleri ve öncelik sistemi doğru çalışıyor
- [ ] Talep durum takip ekranları tasarlandı ve işlevsellik kazandırıldı
- [ ] Talep yanıtlarını yönetme araçları uygulandı
- [ ] Bildirim ve yönlendirme sistemi çalışır durumda
- [ ] Sosyal medya paylaşım fonksiyonları entegre edildi
- [ ] Talep oluşturma ve yanıt süreçleri performanslı ve kullanıcı dostu

📌 **Onay Gereksinimleri**
----------------------
- [ ] Kan talebi formları kullanılabilirlik testlerinden geçti
- [ ] Toplu talep oluşturma işlemi hızlı ve verimli
- [ ] Acil durum taleplerinde uygun bağışçılara bildirim gönderiliyor
- [ ] Talep yanıt oranları ve karşılanma süresi iyileştirildi
- [ ] Veri tutarlılığı ve güvenlik önlemleri uygulandı
- [ ] Taleplerin sosyal medyada görünürlüğü sağlandı
- [ ] Kullanıcı geri bildirimleri ve iyileştirmeler tamamlandı

💡 **Ekstra Notlar**
----------------
- Hasta yakınları için hızlı talep oluşturma modu eklenebilir (acil durumlar için)
- Talep oluşturma ve yanıtlama sürecinde kullanıcı eğitimi/yönlendirmesi eklenmeli
- Bağışçı havuzundan önerilen bağışçıları gösterme seçeneği değerlendirilebilir
- Tamamlanan taleplerin başarı hikayelerinin paylaşımı teşvik edilebilir
- Kan grupları arası uyumluluk bilgilendirmesi eklenebilir
- Özellikle acil durumlarda kolay ve anlaşılır arayüze dikkat edilmeli

🔄 **Ekran Tasarımları**
--------------------
1. **Talep Oluşturma Formları**
   - Hasta yakını talebi: Adım adım form
   - Hastane talebi: Toplu talep arayüzü
   - Lokasyon seçimi ve harita

2. **Talep Yönetim Ekranı**
   - Aktif, tamamlanan ve süresi geçen talepler listesi
   - İlerleme çubukları ve durum göstergeleri
   - Hızlı eylem butonları

3. **Yanıt Yönetim Ekranı**
   - Bağışçı yanıtları listesi
   - Onay/ret işlemleri
   - Bağışçı profil kartları
   - Mesajlaşma arayüzü

4. **Bildirim ve Paylaşım**
   - Bildirim ayarları
   - Sosyal medya paylaşım arayüzü
   - Sonuç ve teşekkür sayfası

🚀 **Faz 7 Çıktıları**
------------------
✅ Tam işlevsel kan talebi oluşturma sistemi
✅ Hasta yakını ve hastane rolleri için özelleştirilmiş arayüzler
✅ Talep yönetim ve takip araçları
✅ Yanıt değerlendirme ve koordinasyon sistemi
✅ Bildirim ve yönlendirme mekanizmaları

🔄 **Sonraki Adım: Harita Görünümü**
-------------------------------
Bir sonraki fazda (Faz 8), uygulamanın harita özelliklerinin geliştirilmesi ele alınacak:
- İnteraktif kan talepleri haritası
- Konum bazlı filtreleme
- Harita üzerinde detay görüntüleme
- Rota oluşturma ve yönlendirme
- Gerçek zamanlı konum güncellemeleri
