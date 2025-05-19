
🚀 KanBul – Faz 4: Rol Tanımlama ve Rol Bazlı Erişim
================================================

🎯 **Hedefler**
--------------
- Kullanıcı tiplerinin (Bireysel, Kurumsal) ve rollerinin (`donor`, `patientRelative`, `hospitalStaff`) tanımlanması.
- Kayıt sırasında kullanıcı tipine göre rollerin atanması.
- Rol bazlı erişim kontrolü sisteminin kurulması (Firestore kuralları ve uygulama içi kontroller).
- Kullanıcının sahip olduğu rollere göre özelleştirilmiş deneyim (Dashboard) sunulması.
- Farklı rollerin görebileceği/kullanabileceği ekran ve içeriklerin yapılandırılması.


📌 **Adım 4.1: Kullanıcı Rol Yapısının Tanımlanması ve Entegrasyonu**
-------------------------------------------------------------------
**Açıklama**
- Uygulama içindeki rollerin (`UserRole` enum: `donor`, `patientRelative`, `hospitalStaff`, `unknown`) tanımlanması.
- Kullanıcı tiplerinin (Bireysel, Kurumsal) belirlenmesi ve kayıt sırasında seçilmesi.
- Bireysel kullanıcıya `donor` ve `patientRelative` rollerinin, Kurumsal kullanıcıya `hospitalStaff` rolünün atanması.
- Firestore'daki `UserModel` içinde rollerin `List<UserRole>` (veya `List<String>`) olarak saklanması.
- Her rol için izinlerin ve yeteneklerin belirlenmesi (hangi rol ne yapabilir?).
- Rol bazlı izin ve kısıtlamaların yönetimi için altyapı kurulumu (`AuthProvider` ve potansiyel yardımcı sınıflar).

🛠 **Kullanılacak Paketler**
--------------------------
- cloud_firestore: ^4.x.x
- provider: ^6.x.x (Mevcut durum yönetimi)
- firebase_auth: ^4.x.x

📝 **Rol Tanımları (Mevcut Durum)**
---------------------------------
```dart
// core/enums/user_role.dart
enum UserRole {
  donor, // Bağışçı
  patientRelative, // Hasta Yakını
  hospitalStaff, // Hastane Personeli
  unknown, // Hata veya belirlenmemiş durum
}

// data/models/user/user_model.dart (Varsayım)
class UserModel {
  final String id;
  final String email;
  final String username;
  final List<UserRole> roles; // Roller liste olarak tutuluyor
  // ... diğer alanlar ...

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    // ...
  });

  // Firestore serializasyonu...
}
```

📌 **Adım 4.2: Kayıt Sırasında Kullanıcı Tipi Seçimi**
----------------------------------------------------
**Açıklama**
- `RegisterScreen` içinde kullanıcı tipi (Bireysel/Kurumsal) seçimi.
- Seçilen tipe göre ilgili rollerin belirlenip `AuthProvider`'ın `signUp` metoduna gönderilmesi.


**UI Bileşenleri (`RegisterScreen` içinde)**
- Kullanıcı tipi seçimi için `RadioListTile` veya benzeri widget'lar (Bireysel/Kurumsal).
- Seçilen tipe göre gösterilen/gizlenen ek bilgi alanları (Kan Grubu / Hastane Adı).
- Kayıt formunun geri kalanı (E-posta, Şifre, Ad, Telefon vb.).

📌 **Adım 4.3: Rol Tabanlı Dashboard ve Navigasyon Yapısı**
-----------------------------------------------------------
**Açıklama**
- Kullanıcının sahip olduğu rollere göre farklı ana ekranların (dashboard) gösterilmesi (`DashboardScreen`).
- Bireysel kullanıcılar (`donor` + `patientRelative`) için sekmeli bir dashboard (`IndividualUserDashboard`) gösterilmesi.
- Kurumsal kullanıcılar (`hospitalStaff`) için `HospitalStaffDashboard` gösterilmesi.
- ~~Bottom navigation bar veya drawer'ın rol bazlı özelleştirilmesi~~ (Henüz Faz 5 konusu, ancak roller burada temel alınacak).
- Rol bazlı erişilebilir sayfaların yönetimi (Örn: Sadece `hospitalStaff` belirli yönetim ekranlarına erişebilir).
- Yetkisiz erişim durumunda kullanıcı yönlendirme (Genellikle Login'e).

📝 **Rol Navigasyon Yapısı (Dashboard İçeriği)**
---------------------------------------------
**Bireysel Kullanıcı Dashboard (`IndividualUserDashboard` - Sekmeli):**
- **Bağışçı Sekmesi (`DonorDashboard`):**
    - Aktif kan talepleri listesi/haritası.
    - Bağış geçmişi özeti.
    - Profil ayarları (ortak olabilir).
- **Hasta Yakını Sekmesi (`PatientRelativeDashboard`):**
    - Oluşturulan kan taleplerini yönetme.
    - Yeni kan talebi oluşturma butonu/formu.
    - Bağışçılarla iletişim (varsa).
    - Profil ayarları (ortak olabilir).

**Kurumsal Kullanıcı Dashboard (`HospitalStaffDashboard`):**
- Hastane kan ihtiyaçları yönetimi.
- Toplu/Bireysel kan talebi oluşturma/yönetme.
- İstatistikler ve raporlar (varsa).
- Hastane/Kullanıcı profil ayarları.

📌 **Adım 4.4: Rol Bazlı Deneyim ve Yetkilendirme**
--------------------------------------------------
**Açıklama**
- Kullanıcının sahip olduğu rollere göre UI bileşenlerinin veya özelliklerin gösterilmesi/gizlenmesi.
- Belirli eylemlerin (örn: kan talebi oluşturma) sadece ilgili rollere sahip kullanıcılar tarafından yapılabilmesi.


**Senaryo Örnekleri (Mevcut Durum)**
- Bireysel kullanıcı, uygulamanın "Hasta Yakını" sekmesinden kan talebi oluşturur, sonra "Bağışçı" sekmesinden başkalarının taleplerine bakar.
- Hastane kullanıcısı, sadece hastane yönetimi ile ilgili özellikleri görür ve kullanır.

**Çözüm Yaklaşımı: Sabit Roller ve Koşullu UI**
- Kullanıcının rolleri kayıt sırasında belirlenir ve değişmez.
- `AuthProvider` üzerinden kullanıcının rolleri (`userRoles` listesi) alınır.
- UI, bu listeye göre dinamik olarak oluşturulur (örn: `DashboardScreen`\'deki `_buildScaffoldForRoles` mantığı).
- Eylemler gerçekleştirilmeden önce `AuthProvider`\'daki `userRoles` listesi kontrol edilir.

**UI Bileşenleri**
- `DashboardScreen`\'de rol listesine göre doğru dashboard\'ın (Sekmeli veya Hastane) gösterilmesi.
- İlgili dashboard\'lar içinde role özel butonların/menülerin gösterilmesi.


📌 **Adım 4.5: Güvenlik ve İzin Kontrolü**
--------------------------------------
**Açıklama**
- Firestore güvenlik kurallarının, kullanıcının `roles` listesine göre yapılandırılması.
- Uygulama içi izin kontrolü için `AuthProvider`\'daki `userRoles` listesinin kullanılması veya yardımcı fonksiyonlar oluşturulması.
- Yetkisiz erişim girişimlerinin uygulama içinde engellenmesi ve loglanması.
- Bazı özellikler için gerekli doğrulama mekanizmaları (özellikle hastane hesapları için - *Bu hala geçerli bir gereksinim olabilir*).

📝 **Örnek Rol İzin Kontrolü (Uygulama İçi)**
------------------------------------------
```dart
// Örnek izin kontrol fonksiyonu (veya AuthProvider içinde metot)
bool canCreateBloodRequest(List<UserRole> userRoles) {
  return userRoles.contains(UserRole.patientRelative) ||
         userRoles.contains(UserRole.hospitalStaff);
}

bool canViewDonorFeatures(List<UserRole> userRoles) {
  return userRoles.contains(UserRole.donor);
}

bool canManageHospitalRequests(List<UserRole> userRoles) {
  return userRoles.contains(UserRole.hospitalStaff);
}

// Kullanımı:
// final authProvider = Provider.of<AuthProvider>(context, listen: false);
// if (canCreateBloodRequest(authProvider.userRoles)) {
//   // Kan talebi oluşturma butonunu göster/etkinleştir
// }
```

**Firestore Güvenlik Kuralları (Güncellenmiş Örnek):**
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Kullanıcı kendi verisini okuyabilir/güncelleyebilir (genişletilebilir)
    match /users/{userId} {
      allow read, update: if request.auth != null && request.auth.uid == userId;
      // Yeni kullanıcı kaydı (Auth servisi tarafından yapılır, kural gerekebilir/gerekmeyebilir)
      // allow create: if request.auth != null;
    }

    // Kan talepleri
    match /bloodRequests/{requestId} {
      // Giriş yapmış herkes okuyabilir
      allow read: if request.auth != null;
      // Sadece patientRelative veya hospitalStaff rolüne sahip kullanıcılar oluşturabilir
      allow create: if request.auth != null &&
                       (request.auth.token.roles.hasAny(['patientRelative', 'hospitalStaff'])); // Custom Claims örneği
                       // VEYA: Firestore okuması ile rol kontrolü (daha maliyetli olabilir)
                       // (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.roles.hasAny(['patientRelative', 'hospitalStaff']));

      // Sadece talep sahibi veya hastane personeli güncelleyebilir/silebilir (örnek)
      allow update, delete: if request.auth != null &&
                               (resource.data.requesterId == request.auth.uid ||
                                request.auth.token.roles.hasAny(['hospitalStaff'])); // Custom Claims örneği
                               // VEYA: Firestore okuması ile rol kontrolü
                               // (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.roles.hasAny(['hospitalStaff']));
    }

    // Diğer koleksiyonlar için kurallar...
    // Örn: Bağışlar, Hastaneler vb.
  }
}
// NOT: Yukarıdaki Firestore kuralları örnektir ve Custom Claims kullandığı varsayılmıştır.
// Custom Claims kullanmıyorsanız, get() ile kullanıcı dokümanını okuyarak rol listesini kontrol etmeniz gerekir.
// Custom Claims, Firestore okuma maliyetini azaltabilir.
```

📌 **Adım 4.6: Rol Bazlı İçerik ve Ekranların Uygulanması**
-------------------------------------------------------
**Açıklama**
- Bireysel ve Kurumsal kullanıcılar için özel widget'lar ve bileşenlerin tasarlanması (`DonorDashboard`, `PatientRelativeDashboard`, `HospitalStaffDashboard` içerikleri).
- Kullanıcının rollerine göre koşullu içerik görüntüleme (`if (authProvider.userRoles.contains(UserRole.donor)) ...`).
- Rol bazlı bildirimlerin yapılandırılması (örn: Yeni talep bildirimi sadece bağışçılara gider).
- Rol-spesifik özelliklerin etkinleştirilmesi (örn: Hastane yönetimi özellikleri sadece `hospitalStaff` için).

📝 **Örnek Rol Bazlı UI (`DashboardScreen` içindeki mantık)**
---------------------------------------------------------
```dart
// features/dashboard/presentation/screens/dashboard_screen.dart
Widget _buildScaffoldForRoles(
  BuildContext context,
  AuthProvider authProvider,
  List<UserRole> roles,
) {
  bool isIndividual = roles.contains(UserRole.donor) && roles.contains(UserRole.patientRelative);
  bool isHospitalStaff = roles.contains(UserRole.hospitalStaff);

  String title = 'Ana Sayfa';
  Widget bodyWidget;
  PreferredSizeWidget? appBarBottom; // TabBar için

  if (isIndividual) {
    title = 'Bireysel Panel';
    bodyWidget = const IndividualUserDashboard(); // Sekmeli dashboard
    appBarBottom = const TabBar( // Sekmeleri tanımla
      tabs: [
        Tab(text: 'Bağışçı', icon: Icon(Icons.bloodtype_outlined)),
        Tab(text: 'Hasta Yakını', icon: Icon(Icons.family_restroom_outlined)),
      ],
    );
  } else if (isHospitalStaff) {
    title = 'Hastane Yönetimi';
    bodyWidget = const HospitalStaffDashboard();
    appBarBottom = null; // Hastane için sekme yok
  } else {
    // Beklenmeyen durum
    title = 'Ana Sayfa';
    bodyWidget = _buildDefaultDashboard(); // Hata/varsayılan ekran
    appBarBottom = null;
  }

  // DefaultTabController MaterialApp etrafına sarıldığı için burada tekrar gerekmez.
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [ /* ... Çıkış butonu ... */ ],
      bottom: appBarBottom, // TabBar'ı ekle
    ),
    body: bodyWidget,
  );
}
```

✅ **Kontrol Noktaları**
--------------------
- [x] Rol modelleri ve enum tanımları oluşturuldu (`UserRole` enum).
- [x] Firebase'de kullanıcı (`UserModel`) içinde rol listesi (`roles`) alanı tasarlandı.
- [x] Kayıt ekranında (`RegisterScreen`) kullanıcı tipi seçimi (Bireysel/Kurumsal) eklendi ve role atama mantığı bağlandı.
- [x] Rol bazlı ana ekranlar (`IndividualUserDashboard` - sekmeli, `HospitalStaffDashboard`) oluşturuldu ve `DashboardScreen`\'de yönlendirme yapıldı.
- [ ] İzin kontrol sistemi (`AuthProvider`\'daki `userRoles` listesi kullanılarak) uygulandı/uygulanıyor.
- [ ] Navigasyon sistemi (`DashboardScreen`) rol bazlı olarak çalışıyor.
- [ ] Firestore güvenlik kuralları rol listesine göre yapılandırıldı/yapılandırılıyor.
- [ ] Rol bazlı bildirimler test edildi/edilecek.

📌 **Onay Gereksinimleri**
----------------------
- [ ] Tüm roller için doğru izinler ve kısıtlamalar uygulandı (Hem UI hem Firestore kuralları).
- [ ] Kayıt akışındaki kullanıcı tipi seçimi kullanıcı dostu ve anlaşılır.
- [ ] Her kullanıcı tipi (Bireysel/Kurumsal) kendi ana ekranına ve ilgili özelliklere erişebiliyor.

- [ ] Yetkisiz erişim denemeleri engelleniyor ve kullanıcı bilgilendiriliyor (UI ve Firestore seviyesinde).
- [ ] Rol bazlı izinler hem client (`AuthProvider`) hem de server tarafında (Firestore kuralları) doğrulanıyor.

💡 **Ekstra Notlar**
----------------
- Hastane rolü (`hospitalStaff`) için ek doğrulama mekanizması düşünülebilir (örn. kurumsal e-posta, manuel onay).

- İleride farklı roller (örn. `admin`) eklenebilecek şekilde esnek bir yapı korunmalı.
- Rol bazlı analitik verilerin toplanması için hazırlık yapılabilir.
- Her rolün kendine özgü gamification elementleri entegre edilebilir.

🔄 **Ekran Tasarımları**
--------------------
1.  **Kayıt Ekranı (`RegisterScreen`)**
    - Kullanıcı tipi seçimi (Bireysel/Kurumsal) için Radio butonlar.
    - Seçime göre değişen ek bilgi alanları (Kan Grubu/Hastane Adı).
2.  **Rol Bazlı Ana Ekranlar (`DashboardScreen` içinde gösterilenler)**
    - **Bireysel Kullanıcı Ana Ekranı (`IndividualUserDashboard`):**
        - `TabBar` (Bağışçı, Hasta Yakını).
        - `TabBarView` içinde `DonorDashboard` ve `PatientRelativeDashboard` içerikleri.
            - **Bağışçı Sekmesi:** Yakındaki kan ihtiyaçları harita/liste görünümü, Son kan talepleri listesi, Bağış geçmişi özeti.
            - **Hasta Yakını Sekmesi:** Aktif taleplerim durumu, Yeni kan talebi oluştur butonu, Taleplerime gelen yanıtlar.
    - **Hastane Personeli Ana Ekranı (`HospitalStaffDashboard`):**
        - Hastane kan stok durumu, Aktif kan talepleri yönetimi, İstatistikler ve raporlar.

🚀 **Faz 4 Çıktıları**
------------------
✅ Sabit rol atama sistemi (Kayıt sırasında).
✅ Rol bazlı kullanıcı arayüzleri (`IndividualUserDashboard`, `HospitalStaffDashboard`).
✅ Rol izin ve kısıtlama mekanizması (UI ve Firestore).
✅ Rol bazlı dashboard yönlendirme sistemi (`DashboardScreen`).

🔄 **Sonraki Adım: Ana Navigasyon (Faz 5)**
-----------------------------------------
Bir sonraki fazda (Faz 5), uygulamanın genel navigasyon yapısı ele alınacak:
- Bottom navigation bar tasarımı (Eğer kullanılacaksa, hangi rollerde görünecek?).
- Drawer menü ve navigasyon yapısı (Profil, Ayarlar, Hakkında vb.).
- Sayfalar arası geçişler ve animasyonlar.
- Genel uygulama akışı ve kullanıcı deneyimi.
