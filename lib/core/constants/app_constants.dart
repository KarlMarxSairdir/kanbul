/// Uygulama genelinde kullanılan sabit değerler
class AppConstants {
  // Private constructor
  AppConstants._();

  // Uygulama bilgileri
  static const String appName = 'KanBul';
  static const String appVersion = '1.0.0';

  // API anahtarları ve URL'ler
  // Not: Bu değerler gerçek uygulamada güvenli bir şekilde saklanmalıdır
  static const String baseApiUrl = 'https://api.kanbul.com';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Hata mesajları
  static const String genericErrorMessage =
      'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkErrorMessage =
      'İnternet bağlantınızı kontrol edin.';

  // Firebase koleksiyonları
  static const String usersCollection = 'users';
  static const String bloodRequestsCollection = 'blood_requests';
  static const String donationsCollection = 'donations';

  // Kan grupları
  static const List<String> bloodTypes = [
    'A Rh+',
    'A Rh-',
    'B Rh+',
    'B Rh-',
    'AB Rh+',
    'AB Rh-',
    '0 Rh+',
    '0 Rh-',
  ];

  // Bağış rozet seviyeleri
  static const int bronzeBadgeCount = 3;
  static const int silverBadgeCount = 7;
  static const int goldBadgeCount = 15;
  static const int platinumBadgeCount = 25;
}
