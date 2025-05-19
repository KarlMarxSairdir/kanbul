import 'package:flutter/material.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/core/theme/app_theme.dart'; // AppTheme import edildi
// TODO: İlgili Provider/Service importları (AuthProvider, FirestoreService vb.)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: Ayar state'lerini tut (örn. bildirim açık mı?)
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;

  @override
  void initState() {
    super.initState();
    logger.d("SettingsScreen: initState");
    // TODO: Mevcut ayarları yükle (AuthProvider veya Firestore'dan)
  }

  // TODO: Ayarları kaydetme fonksiyonu

  @override
  Widget build(BuildContext context) {
    logger.d("SettingsScreen: build");
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Bildirimler'),
            subtitle: const Text('Acil durum ve güncelleme bildirimleri alın'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Ayarı kaydet
            },
            activeColor: AppTheme.primaryColor,
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: AppTheme.iconColor,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Konum Paylaşımı'),
            subtitle: const Text(
              'Yakındaki talepleri görmek için konumunuz kullanılır',
            ),
            value: _locationSharingEnabled,
            onChanged: (bool value) {
              setState(() {
                _locationSharingEnabled = value;
              });
              // TODO: Ayarı kaydet
            },
            activeColor: AppTheme.primaryColor,
            secondary: Icon(
              Icons.location_on_outlined,
              color: AppTheme.iconColor,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_reset_outlined, color: AppTheme.iconColor),
            title: const Text('Şifre Değiştir'),
            onTap: () {
              // TODO: Şifre değiştirme ekranına git
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: AppTheme.errorColor,
            ),
            title: Text(
              'Hesabı Sil',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  // Hesap silme onay dialogu
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hesabı Sil'),
            content: const Text(
              'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'İptal',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                onPressed: () {
                  // TODO: Hesap silme işlemi
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Hesabı Sil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
