// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthStateImpl _$$AuthStateImplFromJson(Map<String, dynamic> json) =>
    _$AuthStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      user: const UserModelConverter()
          .fromJson(json['user'] as Map<String, dynamic>?),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$AuthStateImplToJson(_$AuthStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'user': const UserModelConverter().toJson(instance.user),
      'errorMessage': instance.errorMessage,
    };
