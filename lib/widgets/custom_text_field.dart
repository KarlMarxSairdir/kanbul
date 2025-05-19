import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart'; // Assuming AppTheme.primaryColor exists

/// Tüm uygulama genelinde kullanılacak özel metin girişi bileşeni
class CustomTextField extends StatelessWidget {
  /// Metin alanı etiketi
  final String? label;

  /// Metin alanı ipucu metni
  final String? hintText;

  /// Metin kontrolcüsü
  final TextEditingController? controller;

  /// Değer değiştiğinde çalışacak fonksiyon
  final Function(String)? onChanged;

  /// Form doğrulaması için kullanılacak validasyon fonksiyonu
  final String? Function(String?)? validator;

  /// Metin giriş türü
  final TextInputType keyboardType;

  /// Girişi maske ile formatlama (örn. telefon numarası)
  final List<TextInputFormatter>? inputFormatters;

  /// Şifre alanı mı? (karakterleri gizle)
  final bool obscureText;

  /// Metin alanı simgesi
  final IconData? prefixIcon;

  /// Sonundaki simge
  final Widget? suffixIcon;

  /// Salt okunur mu?
  final bool readOnly;

  /// Tıklandığında çalışacak fonksiyon
  final VoidCallback? onTap;

  /// Maksimum satır sayısı
  final int? maxLines;

  /// Metnin nasıl büyük harfle yazılacağını kontrol eder
  final TextCapitalization textCapitalization;

  /// CustomTextField constructor
  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    // AppTheme'den gelen ana rengi kullan
    final Color primaryColor = AppTheme.primaryColor;
    final Color greyColor = theme.disabledColor; // Daha tematik bir gri tonu
    final Color errorColor = colorScheme.error; // Temanın hata rengi

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alan etiketi
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label!,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                // color: theme.textTheme.bodySmall?.color, // Etiket için tema rengi
              ),
            ),
          ),

        // Metin girişi
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: obscureText ? 1 : maxLines,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      color: theme.iconTheme.color?.withAlpha(
                        (255 * 0.7).toInt(),
                      ), // Temadan ikon rengi
                    )
                    : null,
            suffixIcon: suffixIcon,
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // Kenarlık stillerini tema renkleriyle güncelle
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: greyColor.withAlpha(
                  (255 * 0.5).toInt(),
                ), // Daha hafif gri kenarlık
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: greyColor.withAlpha(
                  (255 * 0.5).toInt(),
                ), // Tutarlı kenarlık
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: primaryColor, // Odaklanıldığında ana renk
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: errorColor, // Temanın hata rengi
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: errorColor, // Temanın hata rengi (odak)
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor:
                theme.inputDecorationTheme.fillColor ??
                colorScheme.surface.withAlpha(
                  (255 * 0.05).toInt(),
                ), // Temadan dolgu rengi veya hafif yüzey rengi
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
            ), // Temadan ipucu stili
          ),
          style: theme.textTheme.bodyLarge, // Temadan metin stili
        ),
      ],
    );
  }
}
