import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings_model.freezed.dart';
part 'user_settings_model.g.dart';

@freezed
class UserSettingsModel with _$UserSettingsModel {
  const factory UserSettingsModel({
    @Default(true) bool notificationsEnabled,
    @Default('public') String privacyLevel,
    @Default(false) bool locationSharingEnabled,
    @Default(false) bool locationPermissionAsked,
  }) = _UserSettingsModel;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);
}