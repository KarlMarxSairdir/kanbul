// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provider yerine Riverpod importu
import 'package:go_router/go_router.dart'; // GoRouter importu
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthProvider yerine authStateNotifierProvider
import 'package:kan_bul/features/auth/providers/auth_action_notifier.dart'; // AuthActionNotifier importu
import 'package:kan_bul/routes/app_routes.dart'; // Rota isimleri için
// import 'package:kan_bul/main.dart'; // Logger için (opsiyonel)

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthNotifier'dan state'i ref.watch ile dinle
    final authState = ref.watch(authStateNotifierProvider);
    final userProfile = authState.user;

    // Profil yüklenirken veya kullanıcı yoksa bir yükleniyor göstergesi döndür
    if (userProfile == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    // Rolü belirle (ileride farklı roller için menü özelleştirilebilir)
    final bool isHospital = userProfile.role.isHospitalStaff;
    // final bool isIndividual = userProfile.role.isIndividual; // Veya bu şekilde

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Üstteki boşluğu kaldır
        children: [
          // Standart ve şık bir başlık alanı
          UserAccountsDrawerHeader(
            accountName: Text(
              userProfile.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(userProfile.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage:
                  userProfile.photoUrl != null
                      ? NetworkImage(userProfile.photoUrl!)
                      : null,
              child:
                  userProfile.photoUrl == null
                      ? Icon(
                        isHospital
                            ? Icons.local_hospital_outlined
                            : Icons.person, // Role göre ikon
                        size: 45.0, // Biraz daha büyük ikon
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                      : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Başlık arka plan rengi
            ),
            // Opsiyonel: Diğer hesapları yönetme butonu vb. eklenebilir
            // otherAccountsPictures: <Widget>[ CircleAvatar(...) ],
          ),

          // Profilim
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              context.push(AppRoutes.profile); // GoRouter ile profile git
            },
          ),

          // Harita (Her iki rol için de ortak olabilir)
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Harita'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              context.push(AppRoutes.map); // GoRouter ile haritaya git
            },
          ),

          // Bağışlarım (Sadece bireysel kullanıcılar için)
          if (!isHospital)
            ListTile(
              leading: const Icon(Icons.favorite_outline), // Veya history ikonu
              title: const Text('Bağışlarım'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.myDonations);
              },
            ),

          // Kan Talepleri (Rol bazlı başlık veya tek link)
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            // Rol bazlı başlık (Opsiyonel)
            title: Text(isHospital ? 'Yönetilen Talepler' : 'Kan Talepleri'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              context.push(
                AppRoutes.bloodRequests,
              ); // Ortak talep listesi rotası
            },
          ),

          // Hastane Personeli için Ekstra Menü (Örnek)
          // if (isHospital)
          //   ListTile(
          //     leading: const Icon(Icons.inventory_2_outlined),
          //     title: const Text('Stok Yönetimi'),
          //     onTap: () {
          //        Navigator.pop(context);
          //       // context.push(AppRoutes.hospitalInventory); // Örnek rota
          //     },
          //   ),
          const Divider(height: 1, thickness: 1), // Ayırıcı
          // Ayarlar
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.settings);
            },
          ),

          // Yardım ve Destek
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Yardım & Destek'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Yardım sayfasına gitmek için context.push kullanın
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yardım sayfası henüz eklenmedi.'),
                ),
              );
            },
          ),

          const Divider(height: 1, thickness: 1), // Ayırıcı
          // Çıkış Yap
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red.shade700,
            ), // Daha belirgin renk
            title: Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red.shade700),
            ),
            onTap: () async {
              // Önce Drawer'ı kapat
              Navigator.pop(context);

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
                // Çıkış işlemi AuthActionNotifier ile yap
                await ref.read(authActionNotifierProvider.notifier).signOut();

                // Firebase Auth'un durumu güncellemesi için kısa bir bekleme
                await Future.delayed(const Duration(milliseconds: 200));

                // Manuel olarak login sayfasına yönlendir
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              } catch (e) {
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
    );
  }
}
