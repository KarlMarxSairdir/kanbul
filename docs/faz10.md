🚀 KanBul – Faz 10: Profil Ekranı ve Bağış Geçmişi
==========================

🎯 **Hedefler**
--------------
- Kullanıcılar için kapsamlı ve kişiselleştirilmiş profil ekranının tasarlanması
- Kullanıcıların kişisel ve sağlık bilgilerini yönetebilmesi için arayüz oluşturulması
- Bağış geçmişinin görüntülenmesi ve istatistiklerin sunulması
- Kullanıcının kazandığı rozetlerin ve başarıların gösterilmesi
- Bildirim ve gizlilik ayarlarının yönetilebilmesi

📌 **Adım 10.1: Profil Ekranının Tasarlanması**
------------------------------------------
**Açıklama**
- Kullanıcı bilgilerinin gösterildiği ana profil ekranının oluşturulması
- Profil fotoğrafı, ad-soyad ve temel bilgilerin düzenlenmesi
- Kullanıcı rolüne göre özelleştirilmiş profil bileşenlerinin geliştirilmesi
- Profil verilerinin Firebase ile senkronizasyonu
- Profil düzenleme işlemlerinin güvenli bir şekilde gerçekleştirilmesi

**UI Bileşenleri**
- Üst bölümde profil fotoğrafı ve temel kullanıcı bilgileri
- Profil düzenleme butonu
- Rol göstergesi (bağışçı, hasta yakını, hastane)
- Kan grubu bilgisi (bağışçı rolü için)
- Hastane adı/bölüm bilgisi (hastane rolü için)
- İletişim bilgileri
- İstatistik kartları

📝 **Örnek Profil Ekranı Kodu**
-------------------------
```dart
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      _profileFuture = UserProfileService().getCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Profil yüklenirken bir hata oluştu'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Profil bilgileri bulunamadı'));
          }

          final profile = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadProfileData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profil üst bölümü
                  _buildProfileHeader(profile),

                  // Profil bilgileri
                  _buildProfileInfo(profile),

                  // Rol bazlı ekstra bilgiler
                  _buildRoleSpecificInfo(profile),

                  // İstatistikler
                  _buildStatistics(profile),

                  // Alt seçenekler
                  _buildProfileOptions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          // Profil fotoğrafı
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
          SizedBox(height: 16),

          // Kullanıcı adı
          Text(
            profile.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Kullanıcı rolü
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleText(profile.role),
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Düzenleme butonu
          ElevatedButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Profili Düzenle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => _navigateToEditProfile(profile),
          ),
        ],
      ),
    );
  }

  // Diğer UI yapı metodları...
}
```

📌 **Adım 10.2: Profil Düzenleme Ekranı**
------------------------------------
**Açıklama**
- Kullanıcı bilgilerinin düzenlenebildiği formların oluşturulması
- İletişim bilgileri, adres, ve kişisel bilgilerin güncellenmesi
- Rol bazlı özelleştirilmiş form alanları
- Sağlık bilgilerinin yönetimi (bağışçılar için)
- Fotoğraf yükleme ve düzenleme arayüzü

**Form Bileşenleri**
- Profil fotoğrafı değiştirme
- İsim, e-posta, telefon, doğum tarihi alanları
- Adres bilgileri formu
- Kan grubu seçimi (bağışçılar için)
- Sağlık geçmişi ve uygunluk bilgileri (bağışçılar için)
- Hastane bilgileri (hastane rolü için)

📝 **Örnek Profil Düzenleme Kodu**
----------------------------
```dart
class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({required this.profile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserProfileModel _profileModel;
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Mevcut profil bilgilerini modele kopyala
    _profileModel = UserProfileModel.fromUserProfile(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Düzenle'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fotoğraf değiştirme
                    _buildProfilePhotoEditor(),

                    SizedBox(height: 24),

                    // Temel bilgiler
                    _buildBasicInfoSection(),

                    SizedBox(height: 16),

                    // İletişim bilgileri
                    _buildContactInfoSection(),

                    SizedBox(height: 16),

                    // Adres bilgileri
                    _buildAddressSection(),

                    SizedBox(height: 16),

                    // Rol bazlı özel alanlar
                    if (_profileModel.role == UserRole.donor)
                      _buildDonorSpecificSection(),

                    if (_profileModel.role == UserRole.hospital)
                      _buildHospitalSpecificSection(),

                    SizedBox(height: 24),

                    // Kaydet butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text('Değişiklikleri Kaydet'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePhotoEditor() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (_profileModel.photoUrl != null
                    ? NetworkImage(_profileModel.photoUrl!)
                    : AssetImage('assets/images/default_avatar.png')
                  ) as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Diğer form bölümleri...

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Profil fotoğrafını yükle
      if (_imageFile != null) {
        final photoUrl = await UserProfileService().uploadProfilePhoto(_imageFile!);
        _profileModel.photoUrl = photoUrl;
      }

      // Profil bilgilerini güncelle
      await UserProfileService().updateUserProfile(_profileModel);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil başarıyla güncellendi')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellenirken hata oluştu: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

📌 **Adım 10.3: Bağış Geçmişi ve İstatistikler**
-------------------------------------------
**Açıklama**
- Kullanıcının geçmiş bağışlarının listelenmesi ve görüntülenmesi
- Bağış istatistiklerinin grafikler ve görsellerle sunulması
- Bağış takvimi ve bir sonraki bağış tarihi hesaplaması
- Bağış geçmişinin filtrelenmesi ve aranması
- Bağış sertifikaları ve belgeleri

**UI Bileşenleri**
- Bağış geçmişi listesi
- İstatistik kartları ve grafikler
- Sonraki uygun bağış tarihi göstergesi
- Filtre ve arama seçenekleri
- Sertifika/belge görüntüleme ve paylaşma

📝 **Örnek Bağış Geçmişi Ekranı Kodu**
--------------------------------
```dart
class DonationHistoryScreen extends StatefulWidget {
  @override
  _DonationHistoryScreenState createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  List<DonationRecord> _donations = [];
  bool _isLoading = true;

  // Filtreleme seçenekleri
  DateTime? _startDate;
  DateTime? _endDate;
  DonationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadDonationHistory();
  }

  Future<void> _loadDonationHistory() async {
    setState(() => _isLoading = true);

    try {
      final userProfile = await UserProfileService().getCurrentUserProfile();

      // Bağış geçmişini yükle
      final donationService = DonationService();
      final donations = await donationService.getUserDonations(
        userId: userProfile.id,
        startDate: _startDate,
        endDate: _endDate,
        status: _selectedStatus,
      );

      setState(() {
        _donations = donations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağış geçmişi yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bağış Geçmişim'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // İstatistik kartları
          _buildStatisticsSection(),

          // Filtreler
          if (_hasActiveFilters())
            _buildActiveFiltersChips(),

          // Bağış listesi
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _donations.isEmpty
                    ? _buildEmptyState()
                    : _buildDonationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    // Toplam bağış sayısı
    final totalDonations = _donations.where(
      (donation) => donation.status == DonationStatus.completed
    ).length;

    // Toplam kurtarılan hayat sayısı (her bağış ortalama 3 kişiye yardım eder)
    final livesSaved = totalDonations * 3;

    // Toplam kan miktarı (1 ünite = 450ml)
    final totalBloodVolume = totalDonations * 450;

    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bağış İstatistikleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                title: 'Toplam Bağış',
                value: totalDonations.toString(),
                icon: Icons.volunteer_activism,
              ),
              _buildStatCard(
                title: 'Kurtarılan Hayat',
                value: livesSaved.toString(),
                icon: Icons.favorite,
              ),
              _buildStatCard(
                title: 'Toplam Kan',
                value: '${(totalBloodVolume / 1000).toStringAsFixed(1)} L',
                icon: Icons.water_drop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Diğer UI metodları...
}
```

📌 **Adım 10.4: Rozetler ve Başarılar**
----------------------------------
**Açıklama**
- Kullanıcının kazandığı rozetlerin ve başarıların görüntülenmesi
- Rozet kazanma koşullarının ve ilerleme durumunun gösterilmesi
- Başarılara göre teşvik mesajları ve motivasyon unsurları
- Rozet detayları ve kazanım hikayeleri
- Sosyal medyada paylaşım özellikleri

**UI Bileşenleri**
- Rozet koleksiyonu görünümü
- Rozet detay kartları
- İlerleme çubukları
- Başarı kilometre taşları
- Paylaşım butonları

📝 **Örnek Rozet Ekranı Kodu**
------------------------
```dart
class BadgesScreen extends StatefulWidget {
  @override
  _BadgesScreenState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Badge> _badges = [];
  List<Badge> _availableBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);

    try {
      final badgeService = BadgeService();

      // Kazanılan rozetler
      final earnedBadges = await badgeService.getUserBadges();

      // Tüm rozetler (kazanılmamış olanlar da dahil)
      final allBadges = await badgeService.getAllBadges();

      // Kazanılmamış rozetleri filtrele
      final availableBadges = allBadges.where(
        (badge) => !earnedBadges.any((earned) => earned.id == badge.id)
      ).toList();

      setState(() {
        _badges = earnedBadges;
        _availableBadges = availableBadges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rozetler yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rozetlerim'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rozet sayısı ve seviye
                  _buildBadgeSummary(),

                  SizedBox(height: 24),

                  // Kazanılan rozetler
                  Text(
                    'Kazanılan Rozetler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _badges.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz rozet kazanmadınız. Bağış yaparak rozetler kazanabilirsiniz.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _buildBadgeGrid(_badges, isEarned: true),

                  SizedBox(height: 32),

                  // Kazanılabilir rozetler
                  Text(
                    'Kazanılabilir Rozetler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildBadgeGrid(_availableBadges, isEarned: false),
                ],
              ),
            ),
    );
  }

  Widget _buildBadgeSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_badges.length} Rozet Kazanıldı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${_availableBadges.length} rozeti daha kazanabilirsiniz',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<Badge> badges, {required bool isEarned}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return GestureDetector(
          onTap: () => _showBadgeDetails(badge, isEarned),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEarned
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBadgeIcon(badge.type),
                  color: isEarned ? Colors.white : Colors.grey[600],
                  size: 32,
                ),
              ),
              SizedBox(height: 8),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Diğer UI metodları...
}
```

📌 **Adım 10.5: Bildirim ve Gizlilik Ayarları**
------------------------------------------
**Açıklama**
- Kullanıcı bildirim tercihlerinin yönetilmesi
- Gizlilik ve veri paylaşımı ayarlarının düzenlenmesi
- Konum paylaşımı ve görünürlük tercihlerinin yönetimi
- Hesap güvenliği ayarları
- Uygulama davranışı ve kullanıcı deneyimi tercihleri

**Ayar Bileşenleri**
- Bildirim tercih anahtarları
- Gizlilik seçenekleri
- Konum paylaşımı ayarları
- Şifre değiştirme formu
- Veri kullanımı kontrolü

📝 **Örnek Ayarlar Ekranı Kodu**
--------------------------
```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final settingsService = UserSettingsService();
      _settings = await settingsService.getUserSettings();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _updateSettings() async {
    setState(() => _isLoading = true);

    try {
      final settingsService = UserSettingsService();
      await settingsService.updateUserSettings(_settings);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar başarıyla güncellendi')),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar güncellenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Bildirimler
                _buildSection(
                  title: 'Bildirimler',
                  children: [
                    SwitchListTile(
                      title: Text('Acil Kan İhtiyacı Bildirimleri'),
                      subtitle: Text('Size uygun acil kan talepleri için bildirim alın'),
                      value: _settings.notifications.emergencyRequests,
                      onChanged: (value) {
                        setState(() {
                          _settings.notifications.emergencyRequests = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text('Randevu Hatırlatıcıları'),
                      subtitle: Text('Yaklaşan bağış randevularınız için hatırlatmalar alın'),
                      value: _settings.notifications.appointmentReminders,
                      onChanged: (value) {
                        setState(() {
                          _settings.notifications.appointmentReminders = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text('Yeni Rozetler'),
                      subtitle: Text('Yeni bir rozet kazandığınızda bildirim alın'),
                      value: _settings.notifications.newBadges,
                      onChanged: (value) {
                        setState(() {
                          _settings.notifications.newBadges = value;
                        });
                        _updateSettings();
                      },
                    ),
                  ],
                ),

                // Gizlilik
                _buildSection(
                  title: 'Gizlilik',
                  children: [
                    SwitchListTile(
                      title: Text('Profilimi Herkese Açık Göster'),
                      subtitle: Text('Profiliniz diğer kullanıcılar tarafından görüntülenebilir'),
                      value: _settings.privacy.publicProfile,
                      onChanged: (value) {
                        setState(() {
                          _settings.privacy.publicProfile = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text('Konum Paylaşımı'),
                      subtitle: Text('Konumunuzu paylaşarak yakınınızdaki kan taleplerine hızlı erişin'),
                      value: _settings.privacy.locationSharing,
                      onChanged: (value) {
                        setState(() {
                          _settings.privacy.locationSharing = value;
                        });
                        _updateSettings();
                      },
                    ),
                    SwitchListTile(
                      title: Text('Bağış Geçmişi Gizliliği'),
                      subtitle: Text('Bağış geçmişiniz profilinizde gösterilecek'),
                      value: _settings.privacy.showDonationHistory,
                      onChanged: (value) {
                        setState(() {
                          _settings.privacy.showDonationHistory = value;
                        });
                        _updateSettings();
                      },
                    ),
                  ],
                ),

                // Hesap güvenliği
                _buildSection(
                  title: 'Hesap Güvenliği',
                  children: [
                    ListTile(
                      title: Text('Şifre Değiştir'),
                      leading: Icon(Icons.lock),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => _navigateToChangePassword(),
                    ),
                    ListTile(
                      title: Text('İki Faktörlü Doğrulama'),
                      leading: Icon(Icons.security),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => _navigateToTwoFactorAuth(),
                    ),
                  ],
                ),

                // Veri ve depolama
                _buildSection(
                  title: 'Veri ve Depolama',
                  children: [
                    ListTile(
                      title: Text('Önbelleği Temizle'),
                      subtitle: Text('${_formatStorageSize(_settings.storage.cacheSize)}'),
                      leading: Icon(Icons.cleaning_services),
                      onTap: () => _clearCache(),
                    ),
                    SwitchListTile(
                      title: Text('Çevrimdışı Erişim'),
                      subtitle: Text('Uygulama verilerine çevrimdışıyken erişin'),
                      value: _settings.storage.offlineAccess,
                      onChanged: (value) {
                        setState(() {
                          _settings.storage.offlineAccess = value;
                        });
                        _updateSettings();
                      },
                    ),
                  ],
                ),

                // Alt bölüm butonları
                ListTile(
                  title: Text('Hesabımı Sil', style: TextStyle(color: Colors.red)),
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () => _showDeleteAccountDialog(),
                ),

                ListTile(
                  title: Text('Çıkış Yap'),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () => _signOut(),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
        Divider(),
      ],
    );
  }

  // Diğer metodlar...
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Profil ekranı tasarlandı ve kullanıcı bilgileri gösteriliyor
- [ ] Profil düzenleme formu oluşturuldu ve çalışıyor
- [ ] Bağış geçmişi ve istatistikler görüntüleniyor
- [ ] Rozetler ve başarılar sistemi entegre edildi
- [ ] Bildirim ve gizlilik ayarları yönetilebiliyor
- [ ] Profil fotoğrafı yükleme ve düzenleme çalışıyor
- [ ] Rol bazlı özelleştirmeler uygulandı
- [ ] Tüm veriler Firebase ile senkronize çalışıyor

📌 **Onay Gereksinimleri**
----------------------
- [ ] Profil ekranı kullanıcı dostu ve sezgisel
- [ ] Profil düzenleme işlemleri sorunsuz çalışıyor
- [ ] Bağış geçmişi ve istatistikler doğru gösteriliyor
- [ ] Rozetler ve başarılar kullanıcıyı motive ediyor
- [ ] Ayarlar kullanıcının tercihlerine göre saklanıyor ve uygulanıyor

💡 **Ekstra Notlar**
----------------
- Profil bilgilerinde kolay erişim için hızlı butonlar eklenebilir
- Bağış geçmişi için takvim görünümü alternatif olarak sunulabilir
- Rozetler için ilerleme çubukları daha fazla motivasyon sağlayabilir
- Sosyal medya hesap bağlantısı eklenebilir
- Farklı profil temaları ve özelleştirme seçenekleri düşünülebilir

🔄 **Ekran Tasarımları**
--------------------
1. **Profil Ekranı**
   - Üst bölümde profil fotoğrafı ve temel bilgiler
   - Özet kartları
   - Alt bölümde seçenekler

2. **Profil Düzenleme Ekranı**
   - Form alanları
   - Profil fotoğrafı değiştirme
   - Kaydetme butonu

3. **Bağış Geçmişi**
   - İstatistik kartları
   - Bağış listesi
   - Filtreler

4. **Rozetler Ekranı**
   - Rozet koleksiyonu
   - İlerleme göstergeleri
   - Başarılar bölümü

5. **Ayarlar Ekranı**
   - Bildirim tercihleri
   - Gizlilik seçenekleri
   - Hesap yönetimi

🚀 **Faz 10 Çıktıları**
------------------
✅ Kapsamlı profil ekranı
✅ Profil düzenleme araçları
✅ Bağış geçmişi ve istatistik gösterimleri
✅ Rozetler ve başarılar sistemi
✅ Bildirim ve gizlilik ayarları

🔄 **Sonraki Adım: Bildirimler ve Uygulamadan Çıkış Sonrası Hatırlatmalar**
-------------------------------------------------------------------
Bir sonraki fazda (Faz 11), bildirimler ve uygulamadan çıkış sonrası hatırlatma sistemleri ele alınacak:
- Push bildirimleri entegrasyonu
- Geofencing ve konum bazlı bildirimler
- Randevu hatırlatmaları
- Kullanıcı katılımını artıran bildirimler
- Acil kan ihtiyacı bildirimleri
