import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  // Dart 2.17+ super parameters kullanımı
  const SectionHeader({
    super.key, // 'Key? key' yerine 'super.key'
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  }); // ': super(key: key)' kaldırıldı

  @override
  Widget build(BuildContext context) {
    // Daha kısa değişken isimleri kullanılabilir
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Varsayılan stiller - mevcut mantık iyi çalışıyor
    final effectiveTitleStyle =
        titleStyle ??
        textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final effectiveSubtitleStyle =
        subtitleStyle ?? textTheme.bodySmall?.copyWith(color: theme.hintColor);

    // Başlık ve alt başlık widget'larını ayırmak okunabilirliği artırabilir
    final Widget titleWidget = Text(title, style: effectiveTitleStyle);
    final Widget? subtitleWidget =
        subtitle != null && subtitle!.isNotEmpty
            ? Padding(
              // SizedBox yerine Padding kullanarak boşluk vermek alternatif olabilir
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(subtitle!, style: effectiveSubtitleStyle),
            )
            : null;

    return Padding(
      // Dış padding için varsayılan değer
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Dikey hizalama
        children: [
          // İkon varsa göster
          if (icon != null) ...[
            Icon(icon, color: theme.primaryColor),
            const SizedBox(width: 8), // İkon ve metin arası boşluk
          ],
          // Başlık ve alt başlık (varsa) için genişleyen alan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Sola hizala
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Dikeyde ortala (özellikle alt başlık yoksa)
              children: [
                titleWidget,
                // Alt başlık widget'ı null değilse göster
                if (subtitleWidget != null) subtitleWidget,
              ],
            ),
          ),
          // Eylem widget'ı varsa göster
          if (action != null) ...[
            const SizedBox(width: 8), // Metin ve eylem arası boşluk
            action!,
          ],
        ],
      ),
    );
  }
}
