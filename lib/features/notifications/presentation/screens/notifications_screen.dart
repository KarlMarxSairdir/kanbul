import 'package:flutter/material.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d("NotificationsScreen: build");
    // TODO: Firestore'dan veya FCM üzerinden gelen bildirimleri listele
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView.builder(
        // Örnek liste yapısı
        itemCount: 5, // Örnek sayı
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Icon(Icons.notifications)),
            title: Text('Bildirim Başlığı ${index + 1}'),
            subtitle: Text(
              'Bu bir örnek bildirim içeriğidir... ${DateTime.now()}',
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              logger.t("Bildirim ${index + 1} tıklandı.");
              // TODO: Bildirime tıklandığında ilgili sayfaya yönlendir (örn. talep detayı)
            },
          );
        },
      ),
    );
  }
}
