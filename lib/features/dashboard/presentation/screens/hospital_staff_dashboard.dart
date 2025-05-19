import 'package:flutter/material.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provider yerine Riverpod
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthProvider yerine AuthNotifier
import 'package:kan_bul/features/auth/providers/auth_action_notifier.dart'; // AuthActionNotifier importu
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/widgets/app_drawer.dart'; // <<< AppDrawer importu eklendi

class HospitalStaffDashboard extends ConsumerStatefulWidget {
  const HospitalStaffDashboard({super.key});

  @override
  ConsumerState<HospitalStaffDashboard> createState() =>
      _HospitalStaffDashboardState();
}

class _HospitalStaffDashboardState extends ConsumerState<HospitalStaffDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    logger.d("HospitalStaffDashboard: initState çağrıldı.");
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    logger.d("HospitalStaffDashboard: dispose çağrıldı.");
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authStateNotifierProvider);
    final userProfile = authState.user;

    if (userProfile == null) {
      logger.w(
        "HospitalStaffDashboard: userProfile null, loading gösteriliyor.",
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!userProfile.role.isHospitalStaff) {
      logger.e(
        "HATA: HospitalStaffDashboard'a hastane personeli olmayan kullanıcı geldi: ${userProfile.role}",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Çıkış yap ve login sayfasına yönlendir
        await ref.read(authActionNotifierProvider.notifier).signOut();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu sayfaya erişim izniniz bulunmuyor.'),
              backgroundColor: Colors.red,
            ),
          );
          context.go(AppRoutes.login);
        }
      });
      return const Scaffold(body: Center(child: Text("Yetkisiz Erişim.")));
    }

    final hospitalName =
        userProfile.profileData.hospitalName ?? userProfile.username;
    logger.d("HospitalStaffDashboard Build: hospitalName=$hospitalName");

    return Scaffold(
      appBar: AppBar(
        title: Text('$hospitalName Paneli'),
        // AppBar'a Drawer'ı açacak ikon otomatik olarak eklenir
        // drawer parametresi verildiğinde.
        actions: [
          // Profil butonu Drawer'da olduğu için buradan kaldırılabilir
          // IconButton(
          //   icon: const Icon(Icons.person_outline),
          //   tooltip: 'Profilim',
          //   onPressed: () {
          //     logger.t("AppBar: Profil ikonuna tıklandı.");
          //     context.push(AppRoutes.profile);
          //   },
          // ),
          IconButton(
            // Çıkış butonu AppBar'da kalabilir
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              logger.i("AppBar: Çıkış yap butonuna tıklandı.");

              // Çıkış onay dialogu göster
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Çıkış Yap'),
                          content: const Text(
                            'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Çıkış Yap',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  ) ??
                  false;

              if (!confirmed) return;

              try {
                // Çıkış işlemi yap
                await ref.read(authActionNotifierProvider.notifier).signOut();

                // Firebase Auth'un durumu güncellemesi için kısa bir bekleme
                await Future.delayed(const Duration(milliseconds: 200));

                // Manuel olarak login sayfasına yönlendir
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              } catch (e) {
                logger.e("HospitalDashboard: Çıkış yapma hatası", error: e);

                // Hata durumunda kullanıcıya bildir
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Çıkış yapılırken bir hata oluştu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // <<< AppDrawer eklendi >>>
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(178),
              tabs: const [
                Tab(text: 'Talepler', icon: Icon(Icons.list_alt_outlined)),
                Tab(text: 'Bağışlar', icon: Icon(Icons.bloodtype_outlined)),
                Tab(text: 'İstatistik', icon: Icon(Icons.bar_chart_outlined)),
              ],
            ),
          ),

          // Tab view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBloodRequestsTab(context),
                _buildDonationManagementTab(context),
                _buildStatisticsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab İçerikleri ---
  Widget _buildBloodRequestsTab(BuildContext context) {
    logger.d("HospitalStaffDashboard: Talepler tab'ı build ediliyor.");
    // TODO: Hastanenin oluşturduğu veya yönettiği kan taleplerini listele (StreamBuilder ile)
    return Center(
      // İçeriği ortala ve padding ekle
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Liste boşken gösterilecek ikon ve metin
            const Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Henüz kan talebi bulunmuyor.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Yeni Talep Butonu
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Yeni Kan Talebi Oluştur'),
              onPressed: () {
                logger.t("Talepler Tab: Yeni talep oluştur butonuna tıklandı.");
                context.push(AppRoutes.createBloodRequest);
              },
            ),
            const SizedBox(height: 10),
            // TODO: Buraya StreamBuilder ile taleplerin listesi gelecek
            // Expanded( child: StreamBuilder<QuerySnapshot>( stream: ..., builder: ... ) )
          ],
        ),
      ),
    );
  }

  Widget _buildDonationManagementTab(BuildContext context) {
    logger.d("HospitalStaffDashboard: Bağış Yönetimi tab'ı build ediliyor.");
    // TODO: Hastaneye gelen bağış yanıtlarını/randevularını listele (StreamBuilder ile)
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bloodtype_sharp,
              size: 60,
              color: Colors.grey,
            ), // İkon değiştirildi
            SizedBox(height: 16),
            Text(
              'Bağış Yönetimi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ), // Başlık kalın
            SizedBox(height: 8),
            Text(
              'Hastaneye yapılan bağış yanıtları ve planlanan randevular burada listelenecektir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            // TODO: Buraya StreamBuilder ile bağış yanıtları/randevular gelecek
            // Expanded( child: StreamBuilder<QuerySnapshot>( stream: ..., builder: ... ) )
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context) {
    logger.d("HospitalStaffDashboard: İstatistik tab'ı build ediliyor.");
    // TODO: Hastane ile ilgili istatistikleri Firestore'dan çek ve göster
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 60,
              color: Colors.grey,
            ), // İkon değiştirildi
            SizedBox(height: 16),
            Text(
              'İstatistikler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Toplam talepler, karşılanan bağışlar gibi istatistiksel veriler burada gösterilecektir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            // TODO: Buraya istatistik kartları veya grafikleri gelecek
          ],
        ),
      ),
    );
  }
}
