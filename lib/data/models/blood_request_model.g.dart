// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BloodRequestImpl _$$BloodRequestImplFromJson(Map<String, dynamic> json) =>
    _$BloodRequestImpl(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorRole: json['creatorRole'] as String,
      bloodType: json['bloodType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      hospitalName: json['hospitalName'] as String,
      unitsNeeded: (json['unitsNeeded'] as num).toInt(),
      urgencyLevel: (json['urgencyLevel'] as num).toInt(),
      location: const GeoPointConverter().fromJson(json['location']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      patientInfo: json['patientInfo'] as String?,
      contactPhone: json['contactPhone'] as String?,
      status: json['status'] as String? ?? 'active',
      responseCount: (json['responseCount'] as num?)?.toInt() ?? 0,
      acceptedDonorIds: (json['acceptedDonorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BloodRequestImplToJson(_$BloodRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'creatorRole': instance.creatorRole,
      'bloodType': instance.bloodType,
      'title': instance.title,
      'description': instance.description,
      'hospitalName': instance.hospitalName,
      'unitsNeeded': instance.unitsNeeded,
      'urgencyLevel': instance.urgencyLevel,
      'location': const GeoPointConverter().toJson(instance.location),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'patientInfo': instance.patientInfo,
      'contactPhone': instance.contactPhone,
      'status': instance.status,
      'responseCount': instance.responseCount,
      'acceptedDonorIds': instance.acceptedDonorIds,
    };
