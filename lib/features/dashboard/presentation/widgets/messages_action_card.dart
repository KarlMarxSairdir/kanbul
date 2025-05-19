import 'package:flutter/material.dart';

/// Mesajlar/Sohbetler ekranına erişim için kart widget'ı
/// Basitleştirilmiş versiyon, sadece tıklama işlevi bekleniyor
class MessagesActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const MessagesActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Tema renklerini doğrudan alalım
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Tertiary renk kullanımı
      color: colorScheme.tertiary.withAlpha((255 * 0.12).round()),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.chat_outlined, size: 36, color: colorScheme.tertiary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesajlarım',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tüm bağış teklifleri ve sohbetlerinizi görüntüleyin',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
