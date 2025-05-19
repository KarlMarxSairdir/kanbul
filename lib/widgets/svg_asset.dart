import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kan_bul/core/utils/logger.dart';

/// SVG yükleme işlemlerini kolaylaştıran yardımcı sınıf
class SvgAsset extends StatelessWidget {
  final String assetName;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? semanticsLabel;

  const SvgAsset({
    required this.assetName,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // SVG dosya yolunu doğru formata çevir
      String path = assetName;
      if (!assetName.startsWith('assets/')) {
        path = 'assets/svg/$assetName';
      }

      // .svg uzantısı yoksa ekle
      if (!path.endsWith('.svg')) {
        path = '$path.svg';
      }

      return Semantics(
        label: semanticsLabel,
        child: SvgPicture.asset(
          path,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    } catch (e) {
      // Hata durumunda hata yerine placeholder göster
      logger.e('SVG yüklenirken hata: $assetName - $e');
      return Container(
        height: height,
        width: width,
        color: Colors.grey.withAlpha((0.3 * 255).round()),
        child: const Icon(Icons.broken_image, color: Colors.red),
      );
    }
  }

  /// SVG varlığının olup olmadığını kontrol eden metod
  static bool assetExists(String assetName) {
    try {
      // SvgPicture.asset kontrolü (gerçek kontrol mantığı projeye göre ayarlanmalı)
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Kullanım örneği:
/// SvgAsset('icon_name') // assets/svg/icon_name.svg yükler
/// SvgAsset('assets/icons/special_icon.svg') // Tam yol belirtilmiş
