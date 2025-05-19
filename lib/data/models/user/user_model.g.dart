// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.unknown,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      settings:
          UserSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
      profileData: UserProfileDataModel.fromJson(
          json['profileData'] as Map<String, dynamic>),
      lastKnownLocation:
          const GeoPointConverter().fromJson(json['lastKnownLocation']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      'role': _$UserRoleEnumMap[instance.role]!,
      if (instance.photoUrl case final value?) 'photoUrl': value,
      'emailVerified': instance.emailVerified,
      'settings': instance.settings.toJson(),
      'profileData': instance.profileData.toJson(),
      if (const GeoPointConverter().toJson(instance.lastKnownLocation)
          case final value?)
        'lastKnownLocation': value,
      if (const TimestampConverter().toJson(instance.createdAt)
          case final value?)
        'createdAt': value,
      if (const TimestampConverter().toJson(instance.updatedAt)
          case final value?)
        'updatedAt': value,
    };

const _$UserRoleEnumMap = {
  UserRole.individual: 'individual',
  UserRole.hospitalStaff: 'hospitalStaff',
  UserRole.unknown: 'unknown',
};
