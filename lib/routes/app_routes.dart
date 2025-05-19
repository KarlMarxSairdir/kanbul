/// KanBul uygulaması için rotalar
/// Not: Bu yapı Faz 5'te GoRouter ile detaylı olarak geliştirilecektir.
class AppRoutes {
  AppRoutes._(); // private constructor

  // Ana rotalar
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authWrapper = '/auth-wrapper';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String permissionRequest = '/permission-request';
  static const String forgotPassword =
      '/forgot-password'; // Şifre sıfırlama ekranı için rota eklendi

  // Ana Dashboard Rotaları
  static const String dashboard =
      '/dashboard'; // Bireysel Kullanıcı Ana Sayfası
  static const String hospitalDashboard =
      '/hospital-dashboard'; // Hastane Personeli Paneli (EKLENDİ)

  // Ortak rotalar (Gelecekteki özellikler için)
  static const String profile = '/profile';
  static const String map = '/map';
  static const String notifications = '/notifications';
  static const String bloodRequests = '/blood-requests'; // Belki talep listesi
  static const String createBloodRequest =
      '/create-blood-request'; // YENİ: Kan talebi oluşturma rotası
  static const String respondToRequest =
      '/respond-to-request'; // YENİ: Talebe yanıt verme rotası

  // Detay rotalar (Gelecekteki özellikler için)
  static const String bloodRequestDetail = '/blood-request-detail';
  // static const String donorDetail = '/donor-detail'; // Belki profil detayı için farklı bir adlandırma

  // YENİ ROTALAR
  static const String myDonations = '/my-donations';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  // static const String help = '/help'; // İleride eklenebilir

  // YENİ TEKLİF VE MESAJLAŞMA ROTALARI
  static const String manageDonationOffers = '/manage-donation-offers';
  static const String manageDonationOffersDetail =
      '/manage-donation-offers/:requestId';
  static const String chat = '/chat';
  static const String myChats = '/my-chats'; // YENİ: Tüm sohbetlere erişim için

  // YENİ BAĞIŞ MERKEZLERİ ROTASI
  static const String donationCenters = '/admin/donation-centers';
}
