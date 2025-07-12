// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatModelImpl _$$ChatModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatModelImpl(
      id: json['id'] as String? ?? '',
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantNames:
          (json['participantNames'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      participantAvatars:
          (json['participantAvatars'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String?),
              ) ??
              const {},
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTimestamp:
          const TimestampConverter().fromJson(json['lastMessageTimestamp']),
      lastReadAt: json['lastReadAt'] == null
          ? const {}
          : const MapTimestampConverter().fromJson(json['lastReadAt']),
    );

Map<String, dynamic> _$$ChatModelImplToJson(_$ChatModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participantIds': instance.participantIds,
      'participantNames': instance.participantNames,
      'participantAvatars': instance.participantAvatars,
      'requestId': instance.requestId,
      'contextId': instance.contextId,
      'lastMessage': instance.lastMessage,
      'lastMessageTimestamp':
          const TimestampConverter().toJson(instance.lastMessageTimestamp),
      'lastReadAt': const MapTimestampConverter().toJson(instance.lastReadAt),
    };
