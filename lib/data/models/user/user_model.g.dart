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
      'phoneNumber': instance.phoneNumber,
      'role': _$UserRoleEnumMap[instance.role]!,
      'photoUrl': instance.photoUrl,
      'emailVerified': instance.emailVerified,
      'settings': instance.settings.toJson(),
      'profileData': instance.profileData.toJson(),
      'lastKnownLocation':
          const GeoPointConverter().toJson(instance.lastKnownLocation),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$UserRoleEnumMap = {
  UserRole.individual: 'individual',
  UserRole.hospitalStaff: 'hospitalStaff',
  UserRole.unknown: 'unknown',
};
