import 'package:flutter/material.dart';

/// KanBul uygulaması için çeviri ve metinler sınıfı
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Uygulama dillerini destekler
  static const List<Locale> supportedLocales = [
    Locale('tr', 'TR'), // Türkçe
    Locale('en', 'US'), // İngilizce
  ];

  // Delegate sınıfı
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Çeviri metinleri
  final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // Genel
      'appName': 'KanBul',
      'continue': 'Devam Et',
      'cancel': 'İptal',
      'save': 'Kaydet',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'error': 'Hata',
      'success': 'Başarılı',

      // Kimlik doğrulama
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'forgotPassword': 'Şifremi Unuttum',
      'email': 'E-posta',
      'password': 'Şifre',
      'confirmPassword': 'Şifreyi Onayla',
      'username': 'Kullanıcı Adı',

      // Kan bağışı
      'bloodDonation': 'Kan Bağışı',
      'donateBlood': 'Kan Bağışla',
      'requestBlood': 'Kan Talebi Oluştur',
      'bloodType': 'Kan Grubu',
    },
    'en': {
      // General
      'appName': 'KanBul',
      'continue': 'Continue',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'error': 'Error',
      'success': 'Success',

      // Authentication
      'login': 'Login',
      'register': 'Register',
      'forgotPassword': 'Forgot Password',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'username': 'Username',

      // Blood donation
      'bloodDonation': 'Blood Donation',
      'donateBlood': 'Donate Blood',
      'requestBlood': 'Request Blood',
      'bloodType': 'Blood Type',
    },
  };

  /// Belirli bir metin anahtarı için çeviri döndürür
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
