// lib/data/models/user/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/enums/user_gender.dart';
import 'package:kan_bul/data/models/user/user_profile_data_model.dart';
import 'package:kan_bul/data/models/user/user_settings_model.dart';
import 'package:kan_bul/data/models/json_converters.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @Default('') String id,
    @Default('') String username,
    @Default('') String email,
    String? phoneNumber,
    @Default(UserRole.unknown) UserRole role,
    String? photoUrl,
    @Default(false) bool emailVerified,
    required UserSettingsModel settings,
    required UserProfileDataModel profileData,
    @GeoPointConverter() GeoPoint? lastKnownLocation,
    @TimestampConverter() Timestamp? createdAt,
    @TimestampConverter() Timestamp? updatedAt,
  }) = _UserModel;

  // Standart Freezed fromJson factory'si
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Güvenli dönüşüm için ek metod
  static UserModel fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) {
      logger.w("UserModel.fromJsonSafe: json null");
      // Boş bir _$UserModelImpl döndür (eski isimlendirme _UserModel)
      return UserModel(
        settings: const UserSettingsModel(),
        profileData: const UserProfileDataModel(),
      );
    }

    try {
      // Gelen dynMap'i düzgün bir String->dynamic map'e çevir
      final data = Map<String, dynamic>.from(json);

      // Şimdi settings ve profileData'yı güvenli bir şekilde çıkart
      dynamic rawSettings = data['settings'];
      dynamic rawProfile = data['profileData'];

      logger.d(
        "UserModel.fromJsonSafe: settings type: ${rawSettings?.runtimeType}, profileData type: ${rawProfile?.runtimeType}",
      );

      // settings alanını güvenli işleme - değeri değiştirmeden
      UserSettingsModel settings;
      if (rawSettings is Map) {
        // Map<String, dynamic>'e dönüştür
        try {
          final settingsMap = Map<String, dynamic>.from(rawSettings);
          settings = UserSettingsModel.fromJsonSafe(settingsMap);
        } catch (e) {
          logger.w("Settings Map'e dönüştürülemedi: $e");
          settings = const UserSettingsModel();
        }
      } else {
        logger.w("Settings map değil veya null: $rawSettings");
        settings = const UserSettingsModel();
      }

      // profileData alanını güvenli işleme - değeri değiştirmeden
      UserProfileDataModel profileData;
      if (rawProfile is Map) {
        // Map<String, dynamic>'e dönüştür
        try {
          final profileMap = Map<String, dynamic>.from(rawProfile);
          profileData = UserProfileDataModel.fromJsonSafe(profileMap);
        } catch (e) {
          logger.w("ProfileData Map'e dönüştürülemedi: $e");
          profileData = const UserProfileDataModel();
        }
      } else {
        logger.w("ProfileData map değil veya null: $rawProfile");
        profileData = const UserProfileDataModel();
      }

      // Temel alanları doldur - güvenli varsayılan değerler kullan
      return UserModel(
        id: data['id'] as String? ?? '',
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phoneNumber: data['phoneNumber'] as String?,
        role: _parseUserRole(data['role']),
        photoUrl: data['photoUrl'] as String?,
        emailVerified: data['emailVerified'] as bool? ?? false,
        settings: settings,
        profileData: profileData,
        lastKnownLocation: _parseGeoPoint(data['lastKnownLocation']),
        createdAt: _parseTimestamp(data['createdAt']),
        updatedAt: _parseTimestamp(data['updatedAt']),
      );
    } catch (e, st) {
      logger.e("UserModel.fromJsonSafe hata: ", error: e, stackTrace: st);
      return UserModel(
        settings: const UserSettingsModel(),
        profileData: const UserProfileDataModel(),
      );
    }
  }

  // UserRole enum'u güvenli parse etme yardımcı metodu
  static UserRole _parseUserRole(dynamic value) {
    if (value == null) return UserRole.unknown;

    if (value is String) {
      try {
        // Metin olarak geçirildiğinde
        return UserRole.values.firstWhere(
          (role) => role.toString().split('.').last == value,
          orElse: () => UserRole.unknown,
        );
      } catch (_) {
        return UserRole.unknown;
      }
    } else if (value is int) {
      // Index olarak geçirildiğinde
      try {
        return UserRole.values[value];
      } catch (_) {
        return UserRole.unknown;
      }
    }

    return UserRole.unknown;
  }

  // GeoPoint güvenli parse etme
  static GeoPoint? _parseGeoPoint(dynamic value) {
    if (value == null) return null;
    if (value is GeoPoint) return value;

    // GeoPoint değil, null döndür
    return null;
  }

  // Timestamp güvenli parse etme
  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;

    // Timestamp değil, null döndür
    return null;
  }
}

// Kullanıcı modeli için yardımcı metodlar
extension UserModelExtension on UserModel {
  bool get isHospitalStaff => role == UserRole.hospitalStaff;
  bool get isIndividualUser => role == UserRole.individual;
  bool get hasRequiredPermissions => settings.locationSharingEnabled;
  Timestamp? get lastDonationTimestamp => profileData.lastDonationDate;

  bool get isDonationAllowed {
    if (role != UserRole.individual ||
        profileData.gender == UserGender.unknown) {
      return false;
    }
    if (profileData.lastDonationDate == null) return true;
    final lastDate = profileData.lastDonationDate!.toDate();
    final wait = profileData.gender.donationWaitDuration;
    return DateTime.now().isAfter(lastDate.add(wait));
  }
}
