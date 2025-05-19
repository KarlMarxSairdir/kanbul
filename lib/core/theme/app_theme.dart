import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fontları için eklendi

/// KanBul uygulaması tema ayarları
class AppTheme {
  // Tema renkleri - Material 3 uyumlu
  // Ana kırmızı tonları
  static const Color primaryColor = Color(0xFFD32F2F); // seed color
  static const Color primaryColorLight = Color(0xFFFFEBEE);
  static const Color primaryColorDark = Color(0xFFB71C1C);

  // Sabit renk referansları
  static const Color errorColor = Color(0xFFBA1A1A); // M3 error color
  static const Color successColor = Color(0xFF2E7D32); // Başarı rengi
  static const Color warningColor = Color(0xFFFB8C00); // Uyarı rengi

  // Zemin renkleri
  static const Color scaffoldBackgroundColor = Color(
    0xFFFFF8F8,
  ); // Ekran zemini özel rengi

  // Metin ve ikon renkleri
  static const Color textPrimaryColor = Color(0xFF1C1B1F); // M3 OnSurface
  static const Color textSecondaryColor = Color(
    0xFF49454F,
  ); // M3 OnSurfaceVariant
  static const Color iconColor = Color(0xFF49454F); // M3 OnSurfaceVariant

  // Özel aciliyet seviyeleri için renkler
  static const Color urgencyCriticalColor = Color(0xFFC62828);
  static const Color urgencyHighColor = Color(0xFFF57C00);
  static const Color urgencyNormalColor = Color(0xFFFFA726);

  // SegmentedButton renkleri
  static const Color segmentedActiveColor = Color(
    0xFFFFD6D6,
  ); // Aktif sekme (Açık kırmızı)
  static const Color segmentedInactiveColor = Color(
    0xFFE5E5E5,
  ); // Pasif sekme (Gri)

  // Tema sabitlerinin private constructor'ı
  AppTheme._();

  /// Açık tema - Material 3 ile tamamen uyumlu
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor:
        scaffoldBackgroundColor, // #FFF8F8 özel arkaplan rengi
    // Seed color ile dinamik renk paleti oluşturma
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // AppBar teması - Material 3 stilinde
    appBarTheme: const AppBarTheme(
      centerTitle: false, // M3 genelde sol hizalı başlık kullanır
      elevation: 0, // M3 düz tasarım
      scrolledUnderElevation: 2, // Kaydırma durumunda hafif yükselti
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Color(0xFF1C1B1F), // Başlık rengi düzeltildi
      ),
    ),

    // Elevated Button - Material 3 stili
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ), // 24px radius
      ),
    ),

    // Filled Button - Material 3'te yeni
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ), // 24px radius
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // OutlinedButton - Material 3 stili
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ), // 24px radius
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // TextButton - Material 3 stili
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ), // 24px radius
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Card teması - M3 stilinde ancak belirtilen özel değerlerle
    cardTheme: CardTheme(
      color: Colors.white, // Kart rengi beyaz
      elevation: 8.0, // 8dp elevation (istenen değer)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // 16px radius
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero, // Sıfır kenar boşluğu, düzen içinde yönetilecek
    ),

    // Chip teması - M3 stilinde yuvarlak köşeler
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // FloatingActionButton - Material 3'te genişletilmiş FAB yaygın
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 3,
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 56),
      backgroundColor: primaryColor, // Ana renk kırmızı
      foregroundColor: Colors.white, // İkon rengi beyaz
      shape: const CircleBorder(), // Yuvarlak FAB
    ),

    // Bottom Navigation Bar - Material 3 stilinde
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD62828), // Seçili ikon #D62828
      unselectedItemColor: Colors.grey.shade600, // #9E9E9E
      selectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600, // SemiBold
      ),
      unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
    ),

    // Bottom App Bar - Material 3 stili
    bottomAppBarTheme: BottomAppBarTheme(
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 80,
      color: Colors.white, // Beyaz background
      shape: const CircularNotchedRectangle(), // FAB için merkezi kesik
    ),

    // Dialog teması
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
    ),

    // Divider teması
    dividerTheme: const DividerThemeData(space: 1, thickness: 1),

    // SnackBar teması - Floating M3 stili
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Input teması - M3 stilinde outline
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Yazı tipleri - Montserrat ve Nunito
    textTheme: GoogleFonts.montserratTextTheme().copyWith(
      // Başlıklar için Montserrat
      displayLarge: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      // Gövde metni için Nunito
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    ),
  );

  // Karanlık tema güncellemeleri burada yapılabilir...
  static final ThemeData darkTheme = ThemeData(
    // ...dark theme kodu
  );

  /// Aciliyet seviyesine göre renk ver
  static Color getUrgencyColor(int urgencyLevel) {
    switch (urgencyLevel) {
      case 3:
        return urgencyCriticalColor;
      case 2:
        return urgencyHighColor;
      case 1:
        return urgencyNormalColor;
      default:
        return Colors.grey;
    }
  }

  // Kan grubu için arka plan rengi
  static Color getBloodTypeBackgroundColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return const Color(0xFFE53935); // Kırmızı tonu
      case 'A-':
        return const Color(0xFFE57373); // Daha açık kırmızı
      case 'B+':
        return const Color(0xFF1565C0); // Mavi tonu
      case 'B-':
        return const Color(0xFF42A5F5); // Daha açık mavi
      case 'AB+':
        return const Color(0xFF6A1B9A); // Mor tonu
      case 'AB-':
        return const Color(0xFFAB47BC); // Daha açık mor
      case '0+':
      case 'O+':
        return const Color(0xFF2E7D32); // Yeşil tonu
      case '0-':
      case 'O-':
        return const Color(0xFF66BB6A); // Daha açık yeşil
      default:
        return Colors.grey; // Bilinmeyen kan grubu
    }
  }
}
