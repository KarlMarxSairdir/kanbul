// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provider yerine Riverpod
import 'package:go_router/go_router.dart'; // GoRouter importu
import 'package:intl/intl.dart'; // Tarih formatlama için (pubspec.yaml'a ekleyin: intl: ^0.19.0)
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthProvider yerine AuthNotifier
import 'package:kan_bul/features/auth/providers/auth_action_notifier.dart'; // AuthActionNotifier importu
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/routes/app_routes.dart'; // Rota isimleri için
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
// TODO: Kendi widget importlarınızı ekleyin (varsa)
// import 'package:kan_bul/widgets/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Tarih formatlama için helper
  String _formatDate(DateTime? date) {
    if (date == null) return 'Belirtilmemiş';
    try {
      // Intl paketi düzgün başlatıldıysa çalışır
      return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
    } catch (e) {
      // Hata durumunda veya locale bulunamazsa basit format
      logger.w("Intl date format error (tr_TR): $e");
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthNotifier'dan kullanıcı bilgilerini al (watch ile dinle)
    final authNotifier = ref.watch(authStateNotifierProvider);
    final userProfile = authNotifier.user;

    // Profil yüklenmemişse veya kullanıcı yoksa (Guard tarafından yakalanmalı ama tedbir)
    if (userProfile == null) {
      logger.w("ProfileScreen: userProfile null, loading gösteriliyor.");
      // Genellikle buraya gelinmez, go_router guard'ı login'e yönlendirmeli
      return const Material(child: Center(child: CircularProgressIndicator()));
    }

    logger.d(
      "ProfileScreen Build: Kullanıcı ${userProfile.username} için profil gösteriliyor.",
    );
    final bool isHospital = userProfile.role.isHospitalStaff;

    // Scaffold'u kaldırıldı, sadece içerik kaldı
    return Material(
      child: Column(
        children: [
          // AppBar'ı sade bir başlık olarak tutuyoruz
          AppBar(title: const Text('Profilim')),
          // İçeriği Expanded içerisine alıyoruz - StatefulShellRoute içinde çalışması için
          Expanded(
            child: ListView(
              // Kaydırılabilir içerik için ListView
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Profil Başlık Alanı ---
                _buildProfileHeader(context, userProfile),
                const SizedBox(height: 24),

                // --- Temel Bilgiler Kartı ---
                _buildInfoCard(context, userProfile, isHospital),
                const SizedBox(height: 24),

                // --- Hesap Ayarları Kartı ---
                _buildAccountSettingsCard(context),
                const SizedBox(height: 24),

                // --- Uygulama Bilgileri Kartı ---
                _buildAppInfoCard(context),

                const SizedBox(height: 32),
                // --- Çıkış Yap Butonu ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Güvenli Çıkış Yap',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600, // Kırmızı renk
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    logger.i("ProfileScreen: Çıkış yap butonuna tıklandı.");

                    // Doğrulama dialogu göster
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
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
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
                      // Çıkış yap
                      // AuthActionNotifier'ı kullan
                      await ref
                          .read(authActionNotifierProvider.notifier)
                          .signOut();

                      // Firebase Auth'un durumu güncellemesi için kısa bir bekleme
                      await Future.delayed(const Duration(milliseconds: 200));

                      // Eğer hala ekrandaysak doğrudan login sayfasına git
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    } catch (e) {
                      logger.e("ProfileScreen: Çıkış yapma hatası", error: e);

                      // Hata durumunda kullanıcıya bildir
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Çıkış yapılırken bir hata oluştu: $e',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profil başlık widget'ı
  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50, // Daha büyük avatar
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child:
              user.photoUrl == null
                  ? Icon(
                    user.role.isHospitalStaff
                        ? Icons.local_hospital
                        : Icons.person,
                    size: 60, // Daha büyük ikon
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                        .withAlpha(204), // 0.8 * 255 = ~204
                  )
                  : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.username,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Chip(
          // Rolü göstermek için Chip
          label: Text(
            user.role.displayName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          avatar: Icon(
            user.role.isHospitalStaff
                ? Icons.business_center_outlined
                : Icons.person_pin_circle_outlined,
            size: 18,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // Temel bilgileri gösteren kart
  Widget _buildInfoCard(BuildContext context, UserModel user, bool isHospital) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kişisel Bilgiler',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildInfoRow(
              Icons.phone_outlined,
              'Telefon',
              user.phoneNumber ?? 'Belirtilmemiş',
            ),

            // Role göre farklı bilgileri göster
            if (!isHospital && user.profileData.bloodType != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.bloodtype_outlined,
                'Kan Grubu',
                user.profileData.bloodType!,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Son Bağış Tarihi',
                _formatDate(user.profileData.lastDonationDate?.toDate()),
              ),
            ] else if (isHospital && user.profileData.hospitalName != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.local_hospital_outlined,
                'Hastane Adı',
                user.profileData.hospitalName!,
              ),
            ],
            const SizedBox(height: 16),
            // Profili Düzenle Butonu
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Bilgileri Düzenle'),
                onPressed: () {
                  logger.t(
                    "ProfileScreen: Bilgileri düzenle butonuna tıklandı.",
                  );
                  context.push(AppRoutes.editProfile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hesap ayarları kartı
  Widget _buildAccountSettingsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Dikey padding
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Şifre Değiştir'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Şifre değiştir tıklandı.");
                // TODO: Şifre Değiştirme Ekranı rotasını tanımla ve git
                // context.push(AppRoutes.changePassword);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre değiştirme henüz eklenmedi.'),
                  ),
                );
              },
            ),
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ), // İçeride divider
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Bildirim Ayarları'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Bildirim Ayarları tıklandı.");
                context.push(
                  AppRoutes.notifications,
                ); // Bildirimler sayfasına git
              },
            ),
            // Başka hesap ayarları eklenebilir
          ],
        ),
      ),
    );
  }

  // Uygulama bilgileri kartı
  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Kullanım Koşulları'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Kullanım Koşulları tıklandı.");
                // TODO: URL Launcher ile ilgili linki aç
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Gizlilik Politikası'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Gizlilik Politikası tıklandı.");
                // TODO: URL Launcher ile ilgili linki aç
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Yardım & Destek'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Yardım & Destek tıklandı.");
                // TODO: Yardım/Destek sayfasına git veya iletişim bilgisi göster
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Uygulama Hakkında'),
              subtitle: const Text(
                'Versiyon 1.0.0',
              ), // Versiyonu dinamik alabilirsin
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                logger.t("ProfileScreen: Uygulama Hakkında tıklandı.");
                // TODO: Hakkında dialogu veya sayfası göster
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bilgi satırı oluşturan yardımcı widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text('$label: ', style: TextStyle(color: Colors.grey[700])),
          Expanded(
            // Değerin taşmasını engelle
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Taşarsa ... koysun
            ),
          ),
        ],
      ),
    );
  }
}
