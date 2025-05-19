🚀 KanBul – Faz 5 (Revize): Ana Navigasyon ve Yönlendirme
🎯 Hedefler
Kullanıcı dostu ve sezgisel bir navigasyon sisteminin tasarlanması (go_router kullanarak).
Sadeleştirilmiş rol yapısına (individual, hospitalStaff) uygun yönlendirme mantığının kurulması.
Farklı ekranlar arasında tutarlı ve akıcı geçişler sağlanması.
Uygulama genelinde ortak navigasyon bileşenlerinin (AppBar, Drawer) entegrasyonu.
Merkezi ve yönetilebilir bir yönlendirme (routing) altyapısı oluşturulması.
📌 Adım 5.1: Navigasyon Mimarisi (go_router) ve Rota Tanımları
Açıklama
Uygulama genelinde go_router paketini kullanarak modern ve bildirimsel (declarative) bir navigasyon şeması oluşturmak.
Gerekli uygulama rotalarını (/, /login, /register, /email-verification, /permission-request, /dashboard, /hospital-dashboard, /profile vb.) tanımlamak.
AuthWrapper'daki yönlendirme mantığını go_router'ın redirect veya refreshListenable özelliklerini kullanarak merkezi hale getirmek.
Derin bağlantılar (deep links) ve bildirim yönlendirmeleri için altyapıyı go_router ile hazırlamak.
🛠 Kullanılacak Ana Paketler
go_router: Modern navigasyon ve yönlendirme için.
provider: AuthProvider'ı dinleyerek yönlendirme kararları vermek için.
animations: (Opsiyonel) Sayfa geçişleri için.
📝 Örnek Rota Yapısı (Revize)
// lib/routes/app_router.dart (veya benzeri)

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash, // Başlangıç rotası Splash olabilir
  refreshListenable: /* AuthProvider Instance */, // Auth durumunu dinle
  redirect: (BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool loggedIn = authProvider.isAuthenticated;
    final bool loggingIn = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register;
    final bool verifyingEmail = state.matchedLocation == AppRoutes.emailVerification;
    final bool requestingPermissions = state.matchedLocation == AppRoutes.permissionRequest;

    // 1. Oturum yoksa ve login/register sayfasında değilse -> Login'e yönlendir
    if (!loggedIn && !loggingIn && state.matchedLocation != AppRoutes.register /* register hariç */) {
      return AppRoutes.login;
    }

    // 2. Oturum varsa
    if (loggedIn) {
      // 2a. E-posta doğrulanmadıysa ve doğrulama sayfasında değilse -> Email Verification'a yönlendir
      if (!authProvider.user!.emailVerified && !verifyingEmail) {
        return AppRoutes.emailVerification;
      }

      // 2b. E-posta doğrulandıysa ama profil/rol yüklenmediyse -> Splash/Loading ekranında kalabilir (veya özel bir loading rotası)
      if (authProvider.user!.emailVerified && authProvider.userProfile == null) {
         // AuthProvider zaten fetch ediyor, go_router bekleyebilir.
         // Veya Loading ekranına yönlendir. Şimdilik null dönmek mevcut ekranda kalmasını sağlar.
         return null; // Veya '/loading-profile'
      }

       // 2c. E-posta doğrulandı, profil yüklendi -> İzinleri kontrol et
       if (authProvider.user!.emailVerified && authProvider.userProfile != null) {
          // İzin kontrolü (SharedPreferences veya başka bir yöntemle)
          // Bu kısım asenkron olduğu için redirect içinde yönetmek zor olabilir.
          // Belki AuthWrapper gibi bir ara katman hala gerekli olabilir veya
          // izin kontrolü sonrası state güncellenip refreshListenable ile tetiklenebilir.
          // ŞİMDİLİK BU KONTROLÜ AuthWrapper'da bırakıp, Wrapper'a yönlendirelim:
          // Eğer login, register, email verification, permission request sayfasındaysa -> AuthWrapper'a git
          if (loggingIn || verifyingEmail || requestingPermissions || state.matchedLocation == AppRoutes.splash) {
             // Kullanıcı zaten izinleri verdi veya atladıysa doğru dashboard'a gitmeli
             // Bu mantık daha detaylı düşünülmeli. Belki SharedPreferences redirect içinde okunabilir?
             // Ya da en basit yol: Giriş/Kayıt/Doğrulama sonrası AuthWrapper'a yönlendir.
             return AppRoutes.authWrapper; // AuthWrapper izin kontrolü yapsın
          }
       }
    }

    // Diğer durumlarda (örn. zaten doğru sayfada ise) yönlendirme yapma
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (context, state) => SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (context, state) => LoginScreen()),
    GoRoute(path: AppRoutes.register, builder: (context, state) => RegisterScreen()),
    GoRoute(path: AppRoutes.emailVerification, builder: (context, state) => EmailVerificationScreen()),
    GoRoute(path: AppRoutes.permissionRequest, builder: (context, state) => PermissionRequestScreen()),

    // AuthWrapper, izin kontrolünden sonra doğru dashboard'a yönlendirecek
    // Veya redirect mantığı tamamen buraya taşınırsa, wrapper'a gerek kalmaz.
    // Şimdilik Wrapper'ı koruyalım:
    GoRoute(
        path: AppRoutes.authWrapper,
        builder: (context, state) => AuthWrapper(), // İçinde izin kontrolü ve dashboard yönlendirmesi var
      ),

    // Ana Dashboard Rotaları (AuthWrapper veya redirect tarafından yönlendirilecek)
    GoRoute(path: AppRoutes.dashboard, builder: (context, state) => DashboardScreen()),
    GoRoute(path: AppRoutes.hospitalDashboard, builder: (context, state) => HospitalStaffDashboard()),

    // Diğer Rotalar (Profil vb. - Bunlar da kimlik doğrulaması gerektirebilir)
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => /* ProfileScreen() */ Scaffold(appBar: AppBar(title: Text('Profil (Yapım Aşamasında)'))), // Örnek
      // Belki profile gitmeden önce redirect ile login kontrolü eklenebilir
    ),
    // ... diğer rotalar ...
  ],
  errorBuilder: (context, state) => /* NotFoundScreen() */ Scaffold(appBar: AppBar(title: Text('Sayfa Bulunamadı')), body: Center(child: Text(state.error.toString()))), // Hata ekranı
);
Use code with caution.
Dart
(Not: go_router'ın redirect fonksiyonu içinde asenkron işlemler (örn. SharedPreferences okuma) doğrudan yapılamaz. Bu nedenle izin kontrolü için ya AuthWrapper gibi bir ara widget kullanmak ya da izin durumunu AuthProvider gibi bir Listenable üzerinde tutup refreshListenable ile yönlendirmeyi tetiklemek daha yaygındır. Yukarıdaki örnekte şimdilik AuthWrapper'ı koruduk.)
📌 Adım 5.2: Ana Uygulama Yapısı ve Ortak Navigasyon Öğeleri
Açıklama
Uygulamanın ana iskeletini (MaterialApp.router) go_router ile kurmak.
Ortak bir AppDrawer widget'ı oluşturmak (Kullanıcı bilgisi, Profil linki, Ayarlar, Yardım, Çıkış). Rol değiştirme özelliği olmayacak.
Hem DashboardScreen (bireysel) hem de HospitalStaffDashboard'un kendi Scaffold'larını, AppBar'larını ve bu ortak AppDrawer'ı kullanmasını sağlamak.
Bireysel kullanıcı için BottomNavigationBar olmayacak. Arayüz DashboardScreen içindeki ListView ve AppBar ile sağlanacak.
Hastane personeli için TabBar navigasyonu (HospitalStaffDashboard içinde) korunacak ve uygulanacak.
📌 Adım 5.3: Drawer Menü Tasarımı (Revize)
Açıklama
Tek ve ortak AppDrawer tasarımı.
Başlıkta kullanıcı adı, e-posta ve profil resmi (varsa).
Menü Öğeleri: Profilim, Ayarlar (varsa), Yardım/Destek, Çıkış Yap.
Rol Değiştirme YOK.
📝 Örnek Drawer Kodu (Revize)
// lib/widgets/app_drawer.dart
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider'dan kullanıcı bilgilerini al
    final authProvider = context.watch<AuthProvider>();
    final userProfile = authProvider.userProfile;
    final user = authProvider.user; // Firebase User

    // Eğer profil henüz yüklenmediyse veya kullanıcı yoksa boş bir Drawer gösterilebilir
    if (userProfile == null || user == null) {
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader( // Daha standart bir görünüm için
            accountName: Text(userProfile.username),
            accountEmail: Text(userProfile.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: userProfile.profilePhotoUrl != null
                  ? NetworkImage(userProfile.profilePhotoUrl!)
                  : null, // Varsayılan ikon için null bırakılabilir
              child: userProfile.profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 40.0, color: Colors.white70)
                  : null,
            ),
            // Diğer hesaplar veya arka plan resmi eklenebilir
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              context.push(AppRoutes.profile); // GoRouter ile profile git
            },
          ),
           ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Harita'), // Örnek ek menü öğesi
            onTap: () {
              Navigator.pop(context);
              // context.push(AppRoutes.map); // Harita rotası
            },
          ),
          // Ekranlara göre diğer kısayollar eklenebilir
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            onTap: () {
               Navigator.pop(context);
              // TODO: Ayarlar sayfasına git
            },
          ),
           ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Yardım & Destek'),
            onTap: () {
               Navigator.pop(context);
               // TODO: Yardım sayfasına git
            },
          ),
          const Divider(),
           ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // Drawer'ı kapat
              await authProvider.signOut();
              // Yönlendirme go_router redirect veya refreshListenable ile otomatik olmalı
            },
          ),
        ],
      ),
    );
  }
}
Use code with caution.
Dart
📌 Adım 5.4: Sayfa Geçiş Animasyonları
--------------------------------------
**Açıklama**
- Sayfalar arası yumuşak ve anlamlı geçiş animasyonlarının tasarlanması
- Farklı geçiş türleri için animasyon koleksiyonu oluşturulması
- Sayfa yükleme durumları için iskelet ekranlar ve yükleme animasyonları
- Hero animasyonlarının kritik UI elementlerine uygulanması

**Animasyon Türleri**
- Fade transition (Solma/belirme)
- Slide transition (Kaydırma)
- Scale transition (Ölçeklendirme)
- Hero transition (Öğe devamlılığı)
- Shared element transition (Paylaşılan öğe geçişi)

📝 **Örnek Sayfa Geçiş Kodu**
------------------------
```dart
// Özel sayfa geçiş animasyonu
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CustomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

// Kullanımı
Navigator.of(context).push(CustomPageRoute(page: DestinationPage()));
```

📌 **Adım 5.5: TabBar Navigasyon Yapısı**
------------------------------------
**Açıklama**
- Belirli ekranlarda tab bazlı alt navigasyon yapısının tasarlanması
- Tab barın görsel stilinin uygulama tasarım diline uyarlanması
- Tab içeriklerinin verimli yüklenmesi için lazy loading uygulanması
- Tab'ler arası kaydırma ve animasyon efektlerinin eklenmesi

**TabBar Kullanılacak Ekranlar**
- Kan Talepleri Ekranı (Aktif / Tamamlanan / İptal Edilen)
- Bağış Geçmişi Ekranı (Son Bağışlarım / Gelecek Randevular)
- Harita Ekranı (Yakındaki Bağışçılar / Yakındaki Merkezler)
- İstatistikler Ekranı (Günlük / Haftalık / Aylık)

📝 **Örnek TabBar Kodu**
-------------------
```dart
// Tab Controller ile sayfa örneği
class BloodRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kan Talepleri'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Aktif', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Tamamlanan', icon: Icon(Icons.check_circle_outline)),
              Tab(text: 'İptal Edilen', icon: Icon(Icons.cancel_outlined)),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: TabBarView(
          children: [
            ActiveRequestsTab(),
            CompletedRequestsTab(),
            CancelledRequestsTab(),
          ],
        ),
      ),
    );
  }
}
```

📌 **Adım 5.6: Navigasyon Durum Yönetimi**
--------------------------------------
**Açıklama**
- Sayfa geçişlerinde durum korunması için state management entegrasyonu
- Sayfa yığını (navigation stack) yönetimi ve optimizasyonu
- Derin bağlantılar ve bildirim yönlendirmeleri için handler'ların oluşturulması
- Geriye dönüş davranışının (back button behavior) özelleştirilmesi
-  go_router kullanarak sayfa parametrelerini yönetmek (örn. /blood-request/:id).
Derin bağlantıları ve bildirim yönlendirmelerini go_router üzerinden yapılandırmak.
Geriye dönüş davranışını kontrol etmek (go_router genellikle bunu iyi yönetir).

**Durum Yönetimi Stratejisi**
- Sayfa parametreleri ve argümanların yapılandırılması
- Sayfa geçmişinin (history) yönetimi
- Koşullu yönlendirmelerin yapılandırılması
- Navigasyon davranışlarının test edilebilirliği

📝 **Örnek Navigasyon Durumu**
-------------------------
```dart
// BLoC kullanarak navigasyon durumu yönetimi
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.home());

  void navigateToHome() => emit(NavigationState.home());

  void navigateToBloodRequests() => emit(NavigationState.bloodRequests());

  void navigateToMap() => emit(NavigationState.map());

  void navigateToProfile() => emit(NavigationState.profile());

  void navigateToBloodRequestDetail(String requestId) =>
      emit(NavigationState.bloodRequestDetail(requestId: requestId));
}

// Durumu dinleyen ana widget
class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Navigator(
          pages: [
            MaterialPage(child: HomeScreen()),
            if (state is BloodRequestsState)
              MaterialPage(child: BloodRequestsScreen()),
            if (state is MapState)
              MaterialPage(child: MapScreen()),
            if (state is ProfileState)
              MaterialPage(child: ProfileScreen()),
            if (state is BloodRequestDetailState)
              MaterialPage(
                child: BloodRequestDetailScreen(
                  requestId: state.requestId,
                ),
              ),
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }

            final NavigationCubit navigationCubit = context.read<NavigationCubit>();
            if (state is BloodRequestDetailState) {
              navigationCubit.navigateToBloodRequests();
            } else if (state is! HomeState) {
              navigationCubit.navigateToHome();
            }

            return true;
          },
        );
      },
    );
  }
}
```

✅ Kontrol Noktaları (Revize)
go_router paketi eklendi ve temel yapılandırma yapıldı (MaterialApp.router).
Gerekli rotalar (/, /login, /dashboard, /hospital-dashboard vb.) tanımlandı.
Merkezi yönlendirme mantığı (go_router redirect/refreshListenable veya AuthWrapper) kuruldu ve çalışıyor.
Ortak AppDrawer oluşturuldu ve ilgili ekranlara eklendi.
HospitalStaffDashboard için TabBar navigasyonu uygulandı.
(Opsiyonel) Sayfa geçiş animasyonları eklendi.
Navigasyon (push/go) çağrıları go_router metotları ile güncellendi.
Geriye dönüş davranışı test edildi.
(İleri Seviye) Derin bağlantı ve bildirim yönlendirmeleri test edildi.
💡 Ekstra Notlar
AuthWrapper'ı tamamen kaldırıp tüm mantığı go_router'ın redirect fonksiyonuna taşımak daha merkezi bir kontrol sağlayabilir, ancak redirect içindeki asenkron kontroller (izinler için SharedPreferences okuma gibi) zorlayıcı olabilir. İzin kontrolünü de AuthProvider state'ine ekleyip refreshListenable ile tetiklemek bir alternatif olabilir.
🚀 Faz 5 Çıktıları (Revize)
✅ go_router tabanlı, merkezi ve yönetilebilir navigasyon sistemi.
✅ Sadeleştirilmiş rol yapısına uygun ekran yönlendirmeleri.
✅ Ortak AppDrawer ve HospitalStaffDashboard için TabBar.
✅ (Opsiyonel) Daha akıcı geçiş animasyonları.
✅ Derin bağlantı ve bildirim yönlendirmeleri için altyapı.

🔄 **Sonraki Adım: Bağışçı Paneli**
-------------------------------
Bir sonraki fazda (Faz 6), bağışçı kullanıcılar için özel işlevler ve arayüzler ele alınacak:
- Bağışçı ana ekranı
- Bağış geçmişi ve takvimi
- Puan ve rozet sistemi
- Gönüllü bağışçı havuzu
- Bildirim tercihleri ve konum ayarları
