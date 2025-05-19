// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsModelImpl _$$UserSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSettingsModelImpl(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      privacyLevel: json['privacyLevel'] as String? ?? 'public',
      locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
      locationPermissionAsked:
          json['locationPermissionAsked'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserSettingsModelImplToJson(
        _$UserSettingsModelImpl instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'privacyLevel': instance.privacyLevel,
      'locationSharingEnabled': instance.locationSharingEnabled,
      'locationPermissionAsked': instance.locationPermissionAsked,
    };
