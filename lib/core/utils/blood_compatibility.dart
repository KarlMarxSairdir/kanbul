// lib/core/utils/blood_compatibility.dart
/// Kan bağış ve alış uyumluluğunu kontrol eden yardımcı sınıf
class BloodCompatibility {
  /// Verilen bir bağışçı kan grubunun hangi gruplara verebileceğini döndürür.
  static List<String> getCompatibleRecipientGroups(String donorBloodType) {
    switch (donorBloodType) {
      case 'O-':
        return ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+']; // Hepsi
      case 'O+':
        return ['O+', 'A+', 'B+', 'AB+'];
      case 'A-':
        return ['A-', 'A+', 'AB-', 'AB+'];
      case 'A+':
        return ['A+', 'AB+'];
      case 'B-':
        return ['B-', 'B+', 'AB-', 'AB+'];
      case 'B+':
        return ['B+', 'AB+'];
      case 'AB-':
        return ['AB-', 'AB+'];
      case 'AB+':
        return ['AB+'];
      default:
        return []; // Bilinmeyen veya geçersiz grup
    }
  }

  /// Verilen bir bağışçının belirli bir talebe kan verip veremeyeceğini kontrol eder.
  static bool canDonateTo(String? donorBloodType, String? recipientBloodType) {
    if (donorBloodType == null || recipientBloodType == null) {
      return false; // Kan grupları bilinmiyorsa uyumsuz kabul et
    }
    final compatibleGroups = getCompatibleRecipientGroups(donorBloodType);
    return compatibleGroups.contains(recipientBloodType);
  }

  /// Verilen bir alıcı kan grubunun hangi gruplardan alabileceğini döndürür.
  static List<String> getCompatibleDonorGroups(String recipientBloodType) {
    switch (recipientBloodType) {
      case 'AB+':
        return ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+']; // Hepsi
      case 'AB-':
        return ['O-', 'A-', 'B-', 'AB-'];
      case 'A+':
        return ['O-', 'O+', 'A-', 'A+'];
      case 'A-':
        return ['O-', 'A-'];
      case 'B+':
        return ['O-', 'O+', 'B-', 'B+'];
      case 'B-':
        return ['O-', 'B-'];
      case 'O+':
        return ['O-', 'O+'];
      case 'O-':
        return ['O-'];
      default:
        return [];
    }
  }

  /// Verilen bir alıcının belirli bir bağışçıdan kan alıp alamayacağını kontrol eder.
  static bool canReceiveFrom(
    String? recipientBloodType,
    String? donorBloodType,
  ) {
    if (recipientBloodType == null || donorBloodType == null) {
      return false;
    }
    final compatibleGroups = getCompatibleDonorGroups(recipientBloodType);
    return compatibleGroups.contains(donorBloodType);
  }
}
