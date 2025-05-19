// lib/data/models/user/user_profile_data_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/data/models/json_converters.dart';
import 'package:kan_bul/core/enums/user_gender.dart';

part 'user_profile_data_model.freezed.dart';
part 'user_profile_data_model.g.dart';

/// Kullanıcı profil bilgilerini tutan model sınıfı
@freezed
class UserProfileDataModel with _$UserProfileDataModel {
  const UserProfileDataModel._(); // İlave metotlar için özel constructor

  const factory UserProfileDataModel({
    // --- Bireysel Kullanıcı Alanları ---
    String? bloodType,
    @TimestampConverter() Timestamp? lastDonationDate,
    @Default(0) int donationCount,
    @Default(true) bool isAvailableToDonate,
    String? medicalInfo,
    @Default(UserGender.unknown) UserGender gender,
    @TimestampConverter() Timestamp? birthDate,
    String? activeRequestId,

    // --- Yeni Eklenen Oyunlaştırma Alanları ---
    @Default(0) int totalLivesSaved,
    @Default(<String>[]) List<String> badges,
    @Default(1) int level,
    @Default(0) int points,
    // --- Yeni Eklenen Randevu Alanları ---
    @TimestampConverter() Timestamp? nextAppointmentDate,
    String? nextAppointmentLocation,
    // --- Konum Bilgisi Alanları ---
    @GeoPointConverter() GeoPoint? location,
    @TimestampConverter() Timestamp? lastLocationUpdate,

    // --- Hastane Kullanıcısı Alanları ---
    String? hospitalName,
    String? hospitalAddress,
    String? hospitalContact,
    @Default(false) bool isHospitalVerified,
    String? associatedDonationCenterId, // <<< YENİ ALAN EKLENDİ
    // Bu, hastane personelinin hangi merkeze bağlı olduğunu tutar.
    // donationCenters koleksiyonundaki bir belge ID'si olacak.
  }) = _UserProfileDataModel;

  factory UserProfileDataModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDataModelFromJson(json);

  /// Rol bilgisine göre JSON'a dönüştürme
  Map<String, dynamic> toJsonWithRole(UserRole role) {
    final json = toJson(); // Bu, Freezed tarafından üretilen standart toJson()

    if (role == UserRole.individual) {
      json.remove('hospitalName');
      json.remove('hospitalAddress');
      json.remove('hospitalContact');
      json.remove('isHospitalVerified');
      json.remove(
        'associatedDonationCenterId',
      ); // Bireysel kullanıcıda bu alan olmaz
    } else if (role == UserRole.hospitalStaff) {
      json.remove('bloodType');
      json.remove('lastDonationDate');
      json.remove('donationCount');
      json.remove('isAvailableToDonate');
      json.remove('activeRequestId');
      json.remove('totalLivesSaved');
      json.remove('badges');
      json.remove('level');
      json.remove('points');
      json.remove('nextAppointmentDate');
      json.remove('nextAppointmentLocation');
      // associatedDonationCenterId hastane personeli için kalmalı.
    }
    // Null değerleri toJson() zaten genellikle handle eder (includeIfNull: false vs.)
    // Eğer özellikle kaldırmak isterseniz bu kalabilir:
    // json.removeWhere((key, value) => value == null);
    return json;
  }

  /// Null güvenli JSON dönüşümü için özel metod
  static UserProfileDataModel fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) {
      // Varsayılan değerlerle bir UserProfileDataModel döndür.
      // Freezed'deki @Default değerleri burada işe yarayacaktır.
      return const UserProfileDataModel();
    }
    try {
      // Standart fromJson'ı kullan, Freezed zaten null ve eksik alanları
      // @Default değerleriyle veya nullable tiplerle ele alacaktır.
      return UserProfileDataModel.fromJson(json);
    } catch (e) {
      // Hata loglanabilir
      // Loglama: logger.e("UserProfileDataModel.fromJsonSafe error: $e", error: e, stackTrace: st);
      return const UserProfileDataModel(); // Hata durumunda varsayılan döndür
    }
  }

  // ... (mevcut diğer metotlarınız: nextEligibleDonationDate, isEligibleToDonate, pointsForNextLevel) ...
  // Bunlar aynı kalabilir.
  DateTime? get nextEligibleDonationDate {
    if (lastDonationDate == null) return null;
    final waitPeriod = gender.donationWaitDuration;
    return lastDonationDate!.toDate().add(waitPeriod);
  }

  bool get isEligibleToDonate {
    if (lastDonationDate == null) return true;
    final nextDate = nextEligibleDonationDate;
    if (nextDate == null) return true;
    return DateTime.now().isAfter(nextDate);
  }

  int get pointsForNextLevel {
    return (level + 1) * 100;
  }
}
