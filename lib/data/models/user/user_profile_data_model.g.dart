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
      if (instance.bloodType case final value?) 'bloodType': value,
      if (const TimestampConverter().toJson(instance.lastDonationDate)
          case final value?)
        'lastDonationDate': value,
      'donationCount': instance.donationCount,
      'isAvailableToDonate': instance.isAvailableToDonate,
      if (instance.medicalInfo case final value?) 'medicalInfo': value,
      'gender': _$UserGenderEnumMap[instance.gender]!,
      if (const TimestampConverter().toJson(instance.birthDate)
          case final value?)
        'birthDate': value,
      if (instance.activeRequestId case final value?) 'activeRequestId': value,
      'totalLivesSaved': instance.totalLivesSaved,
      'badges': instance.badges,
      'level': instance.level,
      'points': instance.points,
      if (const TimestampConverter().toJson(instance.nextAppointmentDate)
          case final value?)
        'nextAppointmentDate': value,
      if (instance.nextAppointmentLocation case final value?)
        'nextAppointmentLocation': value,
      if (const GeoPointConverter().toJson(instance.location) case final value?)
        'location': value,
      if (const TimestampConverter().toJson(instance.lastLocationUpdate)
          case final value?)
        'lastLocationUpdate': value,
      if (instance.hospitalName case final value?) 'hospitalName': value,
      if (instance.hospitalAddress case final value?) 'hospitalAddress': value,
      if (instance.hospitalContact case final value?) 'hospitalContact': value,
      'isHospitalVerified': instance.isHospitalVerified,
      if (instance.associatedDonationCenterId case final value?)
        'associatedDonationCenterId': value,
    };

const _$UserGenderEnumMap = {
  UserGender.male: 'male',
  UserGender.female: 'female',
  UserGender.other: 'other',
  UserGender.unknown: 'unknown',
};
