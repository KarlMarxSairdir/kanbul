/// Uygulama genelinde kullanılan metinleri içerir
class AppStrings {
  // Genel başlıklar
  static const String appName = 'Kan Bul';
  static const String homePage = 'Ana Sayfa';
  static const String profilePage = 'Profil';
  static const String mapPage = 'Harita';
  static const String notificationsPage = 'Bildirimler';
  static const String myChatsPage = 'Mesajlarım';
  static const String donationHistoryPage = 'Bağış Geçmişi';
  static const String chatsPage = 'Mesajlaşma';
  static const String settingsPage = 'Ayarlar';
  static const String helpPage = 'Yardım';

  // Ana Sayfa
  static const String whatWouldYouLikeToDo = 'Ne yapmak istersiniz?';
  static const String activeBloodRequest = 'Aktif Kan Talebiniz';
  static const String nearbyUrgentRequests = 'Yakındaki Acil Talepler';
  static const String donationHistorySummary = 'Bağış Geçmişi Özeti';
  static const String totalDonation = 'Toplam\nBağış';
  static const String lastDonation = 'Son\nBağış';
  static const String savedLives = 'Kurtarılan\nHayat (Tahmini)';
  static const String seeOnMap = 'Haritada Gör';

  // Kart başlıkları ve butonlar
  static const String donateBlood = 'Kan Bağışı Yap';
  static const String donateBloodDesc = 'İhtiyaç sahiplerine yardım edin';
  static const String createBloodRequest = 'Kan Talebi Oluştur';
  static const String manageBloodRequest = 'Talebinizi Yönetin';
  static const String requestBloodDesc = 'Acil durumlar için yardım alın';
  static const String messages = 'Mesajlarım';
  static const String messagesDesc = 'Bağışçılarla iletişime geçin';
  static const String seeAllRequests = 'Tüm Talepleri Gör';

  // Yakındaki talepler
  static const String nearbyRequests = 'Yakınızdaki Talepler';
  static const String noNearbyRequests = 'Yakında Talep Bulunamadı';
  static const String noNearbyRequestsDesc =
      'Çevrenizde şu anda aktif kan talebi bulunmuyor.';
  static const String seeAllRequestsOnMap = 'Haritada Tüm Talepleri Gör';
  static const String loadingNearbyRequests =
      'Yakındaki talepler yükleniyor...';
  static const String noLocationTitle = 'Konum bilgisi alınamadı';
  static const String noLocationDesc =
      'Yakındaki talepleri görmek için konumunuzu paylaşmalısınız.';
  static const String giveLocationPermission = 'Konum İzni Ver';
  static const String distanceNotAvailable = 'Mesafe hesaplanamıyor';
  static const String metersAway = 'metre uzaklıkta';
  static const String kmAway = 'km uzaklıkta';

  // Konum ile ilgili metinler
  static const String locationNotAvailable = 'Konum bilgisi alınamadı';
  static const String locationPermissionDeniedMessage =
      'Konum izni reddedildi. Yakındaki talepleri görmek için konum izni vermelisiniz.';
  static const String locationError = 'Konum hatası';

  // Hata ve bilgilendirme
  static const String errorOccurred = 'Bir sorun oluştu';
  static const String requestsLoadingError =
      'Yakındaki talepler yüklenirken bir hata oluştu.';
  static const String refresh = 'Yenile';
  static const String locationPermissionRequired = 'Konum İzni Gerekli';
  static const String locationPermissionRequiredDesc =
      'Yakındaki talepleri görebilmek için uygulama ayarlarına gidip konum iznini "Her zaman" veya "Uygulamayı kullanırken" olarak ayarlamanız gerekmektedir.';
  static const String cancel = 'İptal';
  static const String settings = 'Ayarlar';
  static const String updateLastDonationDate =
      'Bağış yapmak için profilinizdeki son bağış tarihini güncellemelisiniz.';
  static const String daysUntilNextDonation =
      'Sonraki bağışınıza {days} gün kaldı.';

  // Çıkış yapma
  static const String logout = 'Çıkış Yap';
  static const String loggingOut = 'Çıkış yapılıyor...';
  static const String logoutSuccessful = 'Başarıyla çıkış yapıldı.';
}
