enum UserRole {
  individual, // Bireysel kullanıcı (donor+patientRelative birleşti)
  hospitalStaff, // Hastane/Kan merkezi
  unknown, // Rolü henüz belirlenmemiş veya hata durumu
}

// Firestore'da string olarak saklamak için yardımcı extension
extension UserRoleExtension on UserRole {
  static String toJson(UserRole role) => role.name;

  static UserRole fromJson(String? json) {
    if (json == null) return UserRole.unknown;
    return UserRole.values.firstWhere(
      (role) => role.name == json,
      orElse: () => UserRole.unknown,
    );
  }

  // Rol kontrolü için yardımcı getter'lar
  bool get isIndividual => this == UserRole.individual;
  bool get isHospitalStaff => this == UserRole.hospitalStaff;

  // Kullanıcı dostu görünen isimler
  String get displayName {
    switch (this) {
      case UserRole.individual:
        return 'Bireysel Kullanıcı';
      case UserRole.hospitalStaff:
        return 'Hastane Personeli';
      case UserRole.unknown:
        return 'Bilinmeyen Rol';
    }
  }
}
