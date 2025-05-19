import 'package:flutter/material.dart';

/// "Kan Bağışı Yap" aksiyonu için kart widget'ı
/// Bu versiyon basitleştirilmiş olup, sadece navigasyon fonksiyonu bekliyor
class DonateActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const DonateActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Tema renklerini doğrudan alalım
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Daha güçlü bir renk kullanın, withAlpha ile hafif bir primary rengi tercih edin
      color: colorScheme.primary.withAlpha((0.15 * 255).round()),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bloodtype_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12), // Biraz daha yakın
              Text(
                'Kan Bağışı Yap',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      colorScheme
                          .primary, // Başlık rengini primary ile eşleştir
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4), // Daha yakın bir metin aralığı
              Text(
                'Yakınınızdaki talepleri görüntüleyin',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
