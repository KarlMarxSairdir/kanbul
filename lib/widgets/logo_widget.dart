import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 100}); // Güncellendi

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo1.png', // SVG yerine mevcut PNG kullanılıyor
          height: size,
          width: size,
        ),
        const SizedBox(height: 8.0), // Güncellendi
        Text(
          'KanBul',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).colorScheme.primary, // Tema rengi kullanıldı
          ),
        ),
      ],
    );
  }
}
