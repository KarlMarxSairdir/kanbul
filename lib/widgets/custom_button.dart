import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Tüm uygulama genelinde kullanılacak özel buton bileşeni
class CustomButton extends StatelessWidget {
  /// Buton metni
  final String text;

  /// Butona tıklandığında çalışacak fonksiyon
  final VoidCallback onPressed;

  /// Butonun genişlik değeri (null ise maksimum genişlik kullanılır)
  final double? width;

  /// Buton yüksekliği
  final double height;

  /// Buton devre dışı mı?
  final bool isDisabled;

  /// Buton dolgu tipi
  final bool isPrimary;

  /// Yükleniyor göstergesini görüntüle
  final bool isLoading;

  /// İkon (opsiyonel)
  final IconData? icon;

  /// İkon konumu (başta veya sonda)
  final bool iconAtEnd;

  /// CustomButton constructor
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 50.0,
    this.isDisabled = false,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    // Temadan buton stilini alıp üzerine özelleştirmeler yapalım
    final ButtonStyle? baseStyle =
        isPrimary
            ? Theme.of(context).elevatedButtonTheme.style
            : Theme.of(context).textButtonTheme.style?.copyWith(
              // Veya OutlinedButton teması
              // İkincil buton için kenarlık ekleyelim
              side: WidgetStateProperty.resolveWith<BorderSide>((
                // <<< DEĞİŞTİ
                Set<WidgetState> states, // <<< DEĞİŞTİ
              ) {
                return BorderSide(
                  color:
                      states.contains(WidgetState.disabled) // <<< DEĞİŞTİ
                          ? Colors.grey.shade400
                          : AppTheme.primaryColor, // Devre dışıysa gri kenarlık
                  width: 1.5, // Kenarlık kalınlığı
                );
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((
                // <<< DEĞİŞTİ
                Set<WidgetState> states, // <<< DEĞİŞTİ
              ) {
                if (states.contains(WidgetState.disabled)) {
                  // <<< DEĞİŞTİ
                  return Colors.grey.shade400; // Devre dışı metin rengi
                }
                return AppTheme.primaryColor; // Normal metin rengi
              }),
              backgroundColor: WidgetStateProperty.all<Color>(
                // <<< DEĞİŞTİ
                Colors.transparent,
              ), // Arka plan şeffaf
              elevation: WidgetStateProperty.all<double>(
                0,
              ), // <<< DEĞİŞTİ // Gölge yok
            );

    final buttonStyle = (baseStyle ?? ElevatedButton.styleFrom()).copyWith(
      // Genel boyut ve şekil ayarları
      minimumSize: WidgetStateProperty.all<Size>(
        // <<< DEĞİŞTİ
        Size(width ?? double.infinity, height),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        // <<< DEĞİŞTİ
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ), // Padding biraz artırıldı
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        // <<< DEĞİŞTİ
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), // Köşe yuvarlaklığı biraz artırıldı
      ),
      // isPrimary durumuna göre renkler (Tema stilini eziyoruz)
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        // <<< DEĞİŞTİ
        Set<WidgetState> states, // <<< DEĞİŞTİ
      ) {
        if (states.contains(WidgetState.disabled)) {
          // <<< DEĞİŞTİ
          return Colors.grey.shade300; // Devre dışı arka plan rengi
        }
        return isPrimary
            ? AppTheme.primaryColor
            : Colors.transparent; // Ana veya şeffaf
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        // <<< DEĞİŞTİ
        Set<WidgetState> states, // <<< DEĞİŞTİ
      ) {
        if (states.contains(WidgetState.disabled)) {
          // <<< DEĞİŞTİ
          return Colors.grey.shade500; // Devre dışı ön plan (metin/ikon) rengi
        }
        return isPrimary
            ? Colors.white
            : AppTheme.primaryColor; // Beyaz veya ana renk
      }),
      // isPrimary true ise hafif bir gölge, değilse 0
      elevation: WidgetStateProperty.all<double>(
        // <<< DEĞİŞTİ
        isPrimary ? (isDisabled ? 0 : 2.0) : 0,
      ),
      // isPrimary false ise kenarlık (yukarıda textButtonTheme'den alındı, burada tekrar ezilebilir veya oradan kullanılır)
      side:
          isPrimary
              ? null
              : WidgetStateProperty.resolveWith<BorderSide>((
                // <<< DEĞİŞTİ
                Set<WidgetState> states, // <<< DEĞİŞTİ
              ) {
                return BorderSide(
                  color:
                      states.contains(WidgetState.disabled) // <<< DEĞİŞTİ
                          ? Colors.grey.shade400
                          : AppTheme.primaryColor,
                  width: 1.5,
                );
              }),
    );

    final Widget child =
        isLoading
            ? SizedBox(
              // <<< DEĞİŞTİ: const kaldırıldı
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                // isLoading durumunda ön plan rengini (beyaz veya primaryColor) kullan
                color: isPrimary ? Colors.white : AppTheme.primaryColor,
                strokeWidth: 2.0,
              ),
            )
            : _buildButtonContent();

    // ElevatedButton veya TextButton/OutlinedButton kullanmaya gerek yok,
    // stil zaten her şeyi yönetiyor.
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _buildButtonContent() {
    // isLoading false ise içeriği oluştur
    final textWidget = Text(text);
    if (icon == null) {
      return textWidget;
    }

    // isPrimary'ye göre ikon rengini belirle (foregroundColor'dan alınabilir ama burada daha direkt)
    // final iconColor = isPrimary ? Colors.white : AppTheme.primaryColor;
    // Not: foregroundColor zaten bunu yönettiği için tekrar ayarlamaya gerek yok.

    final iconWidget = Icon(icon, size: 18); // İkon rengi style'dan gelecek

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          iconAtEnd
              ? [textWidget, const SizedBox(width: 8), iconWidget]
              : [iconWidget, const SizedBox(width: 8), textWidget],
    );
  }
}
