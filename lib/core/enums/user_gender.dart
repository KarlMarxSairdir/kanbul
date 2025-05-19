// lib/core/enums/user_gender.dart

/// Kullanıcı cinsiyet seçeneklerini tutan enum
enum UserGender {
  male, // Erkek
  female, // Kadın
  other, // Diğer
  unknown, // Belirtilmemiş
}

/// Helper extension (UserGender için yardımcı metotlar)
extension UserGenderExtension on UserGender {
  String toJson() => name; // enum'ı string'e çevirir (male, female vb.)

  static UserGender fromJson(String? jsonValue) {
    if (jsonValue == null || jsonValue.isEmpty) {
      return UserGender.unknown;
    }

    // Büyük/küçük harf duyarsız karşılaştırma için küçük harfe çevir
    final lowerJson = jsonValue.toLowerCase();

    // Enum değerlerini direkt eşleştirmeyi dene
    for (var gender in UserGender.values) {
      if (gender.name.toLowerCase() == lowerJson) {
        return gender;
      }
    }

    // Türkçe cinsiyet adlarını kontrol et
    switch (lowerJson) {
      case 'erkek':
        return UserGender.male;
      case 'kadın':
      case 'kadin':
        return UserGender.female;
      case 'diğer':
      case 'diger':
      case 'belirtmek istemiyorum':
        return UserGender.other;
      default:
        return UserGender.unknown;
    }
  }

  // Bekleme süresini doğrudan buradan alabiliriz (kan bağışı için bekleme süresi)
  Duration get donationWaitDuration {
    switch (this) {
      case UserGender.female:
        return const Duration(days: 120); // Kadınlar için 4 ay
      case UserGender.male:
        return const Duration(days: 90); // Erkekler için 3 ay
      default: // other, unknown için varsayılan
        return const Duration(days: 90); // Veya farklı bir kural
    }
  }

  // Cinsiyet için kullanıcı dostu görünüm metni
  String get displayText {
    switch (this) {
      case UserGender.male:
        return 'Erkek';
      case UserGender.female:
        return 'Kadın';
      case UserGender.other:
        return 'Diğer';
      case UserGender.unknown:
        return 'Belirtilmemiş';
    }
  }
}

// Top-level fonksiyon (JSON serileştirme için)
UserGender userGenderFromJson(String? jsonValue) =>
    UserGenderExtension.fromJson(jsonValue);
