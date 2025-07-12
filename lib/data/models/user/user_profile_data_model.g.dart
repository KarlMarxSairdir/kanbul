// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileDataModelImpl _$$UserProfileDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileDataModelImpl(
      bloodType: json['bloodType'] as String?,
      lastDonationDate:
          const TimestampConverter().fromJson(json['lastDonationDate']),
      donationCount: (json['donationCount'] as num?)?.toInt() ?? 0,
      isAvailableToDonate: json['isAvailableToDonate'] as bool? ?? true,
      medicalInfo: json['medicalInfo'] as String?,
      gender: $enumDecodeNullable(_$UserGenderEnumMap, json['gender']) ??
          UserGender.unknown,
      birthDate: const TimestampConverter().fromJson(json['birthDate']),
      activeRequestId: json['activeRequestId'] as String?,
      totalLivesSaved: (json['totalLivesSaved'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      level: (json['level'] as num?)?.toInt() ?? 1,
      points: (json['points'] as num?)?.toInt() ?? 0,
      nextAppointmentDate:
          const TimestampConverter().fromJson(json['nextAppointmentDate']),
      nextAppointmentLocation: json['nextAppointmentLocation'] as String?,
      location: const GeoPointConverter().fromJson(json['location']),
      lastLocationUpdate:
          const TimestampConverter().fromJson(json['lastLocationUpdate']),
      hospitalName: json['hospitalName'] as String?,
      hospitalAddress: json['hospitalAddress'] as String?,
      hospitalContact: json['hospitalContact'] as String?,
      isHospitalVerified: json['isHospitalVerified'] as bool? ?? false,
      associatedDonationCenterId: json['associatedDonationCenterId'] as String?,
    );

Map<String, dynamic> _$$UserProfileDataModelImplToJson(
        _$UserProfileDataModelImpl instance) =>
    <String, dynamic>{
      'bloodType': instance.bloodType,
      'lastDonationDate':
          const TimestampConverter().toJson(instance.lastDonationDate),
      'donationCount': instance.donationCount,
      'isAvailableToDonate': instance.isAvailableToDonate,
      'medicalInfo': instance.medicalInfo,
      'gender': _$UserGenderEnumMap[instance.gender]!,
      'birthDate': const TimestampConverter().toJson(instance.birthDate),
      'activeRequestId': instance.activeRequestId,
      'totalLivesSaved': instance.totalLivesSaved,
      'badges': instance.badges,
      'level': instance.level,
      'points': instance.points,
      'nextAppointmentDate':
          const TimestampConverter().toJson(instance.nextAppointmentDate),
      'nextAppointmentLocation': instance.nextAppointmentLocation,
      'location': const GeoPointConverter().toJson(instance.location),
      'lastLocationUpdate':
          const TimestampConverter().toJson(instance.lastLocationUpdate),
      'hospitalName': instance.hospitalName,
      'hospitalAddress': instance.hospitalAddress,
      'hospitalContact': instance.hospitalContact,
      'isHospitalVerified': instance.isHospitalVerified,
      'associatedDonationCenterId': instance.associatedDonationCenterId,
    };

const _$UserGenderEnumMap = {
  UserGender.male: 'male',
  UserGender.female: 'female',
  UserGender.other: 'other',
  UserGender.unknown: 'unknown',
};
