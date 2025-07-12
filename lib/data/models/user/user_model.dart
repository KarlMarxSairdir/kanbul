import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/enums/user_gender.dart';
import 'package:kan_bul/data/models/user/user_profile_data_model.dart';
import 'package:kan_bul/data/models/user/user_settings_model.dart';
import 'package:kan_bul/data/models/json_converters.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

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
