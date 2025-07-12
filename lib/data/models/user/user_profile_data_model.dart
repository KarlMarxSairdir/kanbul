import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/data/models/json_converters.dart';
import 'package:kan_bul/core/enums/user_gender.dart';

part 'user_profile_data_model.freezed.dart';
part 'user_profile_data_model.g.dart';

@freezed
class UserProfileDataModel with _$UserProfileDataModel {
  const UserProfileDataModel._();

  const factory UserProfileDataModel({
    String? bloodType,
    @TimestampConverter() Timestamp? lastDonationDate,
    @Default(0) int donationCount,
    @Default(true) bool isAvailableToDonate,
    String? medicalInfo,
    @Default(UserGender.unknown) UserGender gender,
    @TimestampConverter() Timestamp? birthDate,
    String? activeRequestId,
    @Default(0) int totalLivesSaved,
    @Default(<String>[]) List<String> badges,
    @Default(1) int level,
    @Default(0) int points,
    @TimestampConverter() Timestamp? nextAppointmentDate,
    String? nextAppointmentLocation,
    @GeoPointConverter() GeoPoint? location,
    @TimestampConverter() Timestamp? lastLocationUpdate,
    String? hospitalName,
    String? hospitalAddress,
    String? hospitalContact,
    @Default(false) bool isHospitalVerified,
    String? associatedDonationCenterId,
  }) = _UserProfileDataModel;

  factory UserProfileDataModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDataModelFromJson(json);

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

  int get pointsForNextLevel => (level + 1) * 100;
}