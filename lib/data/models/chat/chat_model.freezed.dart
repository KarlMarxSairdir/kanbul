// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) {
  return _ChatModel.fromJson(json);
}

/// @nodoc
mixin _$ChatModel {
  String get id => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  Map<String, String> get participantNames =>
      throw _privateConstructorUsedError;
  Map<String, String?> get participantAvatars =>
      throw _privateConstructorUsedError;
  String get requestId => throw _privateConstructorUsedError;
  String? get contextId =>
      throw _privateConstructorUsedError; // Yanıt onaylandığında kullanılan donationResponse.id
  String? get lastMessage =>
      throw _privateConstructorUsedError; // Varsayılan boş string
  @ServerTimestamp()
  @TimestampConverter()
  Timestamp? get lastMessageTimestamp => throw _privateConstructorUsedError;
  @MapTimestampConverter()
  Map<String, Timestamp> get lastReadAt => throw _privateConstructorUsedError;

  /// Serializes this ChatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatModelCopyWith<ChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatModelCopyWith<$Res> {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) then) =
      _$ChatModelCopyWithImpl<$Res, ChatModel>;
  @useResult
  $Res call(
      {String id,
      List<String> participantIds,
      Map<String, String> participantNames,
      Map<String, String?> participantAvatars,
      String requestId,
      String? contextId,
      String? lastMessage,
      @ServerTimestamp() @TimestampConverter() Timestamp? lastMessageTimestamp,
      @MapTimestampConverter() Map<String, Timestamp> lastReadAt});
}

/// @nodoc
class _$ChatModelCopyWithImpl<$Res, $Val extends ChatModel>
    implements $ChatModelCopyWith<$Res> {
  _$ChatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participantIds = null,
    Object? participantNames = null,
    Object? participantAvatars = null,
    Object? requestId = null,
    Object? contextId = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
    Object? lastReadAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value.participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantAvatars: null == participantAvatars
          ? _value.participantAvatars
          : participantAvatars // ignore: cast_nullable_to_non_nullable
              as Map<String, String?>,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _value.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      lastReadAt: null == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as Map<String, Timestamp>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatModelImplCopyWith<$Res>
    implements $ChatModelCopyWith<$Res> {
  factory _$$ChatModelImplCopyWith(
          _$ChatModelImpl value, $Res Function(_$ChatModelImpl) then) =
      __$$ChatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<String> participantIds,
      Map<String, String> participantNames,
      Map<String, String?> participantAvatars,
      String requestId,
      String? contextId,
      String? lastMessage,
      @ServerTimestamp() @TimestampConverter() Timestamp? lastMessageTimestamp,
      @MapTimestampConverter() Map<String, Timestamp> lastReadAt});
}

/// @nodoc
class __$$ChatModelImplCopyWithImpl<$Res>
    extends _$ChatModelCopyWithImpl<$Res, _$ChatModelImpl>
    implements _$$ChatModelImplCopyWith<$Res> {
  __$$ChatModelImplCopyWithImpl(
      _$ChatModelImpl _value, $Res Function(_$ChatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participantIds = null,
    Object? participantNames = null,
    Object? participantAvatars = null,
    Object? requestId = null,
    Object? contextId = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
    Object? lastReadAt = null,
  }) {
    return _then(_$ChatModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value._participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantAvatars: null == participantAvatars
          ? _value._participantAvatars
          : participantAvatars // ignore: cast_nullable_to_non_nullable
              as Map<String, String?>,
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _value.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      lastReadAt: null == lastReadAt
          ? _value._lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as Map<String, Timestamp>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatModelImpl implements _ChatModel {
  const _$ChatModelImpl(
      {this.id = '',
      required final List<String> participantIds,
      final Map<String, String> participantNames = const {},
      final Map<String, String?> participantAvatars = const {},
      required this.requestId,
      this.contextId,
      this.lastMessage = '',
      @ServerTimestamp() @TimestampConverter() this.lastMessageTimestamp,
      @MapTimestampConverter()
      final Map<String, Timestamp> lastReadAt = const {}})
      : _participantIds = participantIds,
        _participantNames = participantNames,
        _participantAvatars = participantAvatars,
        _lastReadAt = lastReadAt;

  factory _$ChatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  final Map<String, String> _participantNames;
  @override
  @JsonKey()
  Map<String, String> get participantNames {
    if (_participantNames is EqualUnmodifiableMapView) return _participantNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantNames);
  }

  final Map<String, String?> _participantAvatars;
  @override
  @JsonKey()
  Map<String, String?> get participantAvatars {
    if (_participantAvatars is EqualUnmodifiableMapView)
      return _participantAvatars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantAvatars);
  }

  @override
  final String requestId;
  @override
  final String? contextId;
// Yanıt onaylandığında kullanılan donationResponse.id
  @override
  @JsonKey()
  final String? lastMessage;
// Varsayılan boş string
  @override
  @ServerTimestamp()
  @TimestampConverter()
  final Timestamp? lastMessageTimestamp;
  final Map<String, Timestamp> _lastReadAt;
  @override
  @JsonKey()
  @MapTimestampConverter()
  Map<String, Timestamp> get lastReadAt {
    if (_lastReadAt is EqualUnmodifiableMapView) return _lastReadAt;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastReadAt);
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, participantIds: $participantIds, participantNames: $participantNames, participantAvatars: $participantAvatars, requestId: $requestId, contextId: $contextId, lastMessage: $lastMessage, lastMessageTimestamp: $lastMessageTimestamp, lastReadAt: $lastReadAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            const DeepCollectionEquality()
                .equals(other._participantNames, _participantNames) &&
            const DeepCollectionEquality()
                .equals(other._participantAvatars, _participantAvatars) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.contextId, contextId) ||
                other.contextId == contextId) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTimestamp, lastMessageTimestamp) ||
                other.lastMessageTimestamp == lastMessageTimestamp) &&
            const DeepCollectionEquality()
                .equals(other._lastReadAt, _lastReadAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_participantIds),
      const DeepCollectionEquality().hash(_participantNames),
      const DeepCollectionEquality().hash(_participantAvatars),
      requestId,
      contextId,
      lastMessage,
      lastMessageTimestamp,
      const DeepCollectionEquality().hash(_lastReadAt));

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatModelImplCopyWith<_$ChatModelImpl> get copyWith =>
      __$$ChatModelImplCopyWithImpl<_$ChatModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatModelImplToJson(
      this,
    );
  }
}

abstract class _ChatModel implements ChatModel {
  const factory _ChatModel(
          {final String id,
          required final List<String> participantIds,
          final Map<String, String> participantNames,
          final Map<String, String?> participantAvatars,
          required final String requestId,
          final String? contextId,
          final String? lastMessage,
          @ServerTimestamp()
          @TimestampConverter()
          final Timestamp? lastMessageTimestamp,
          @MapTimestampConverter() final Map<String, Timestamp> lastReadAt}) =
      _$ChatModelImpl;

  factory _ChatModel.fromJson(Map<String, dynamic> json) =
      _$ChatModelImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get participantIds;
  @override
  Map<String, String> get participantNames;
  @override
  Map<String, String?> get participantAvatars;
  @override
  String get requestId;
  @override
  String? get contextId; // Yanıt onaylandığında kullanılan donationResponse.id
  @override
  String? get lastMessage; // Varsayılan boş string
  @override
  @ServerTimestamp()
  @TimestampConverter()
  Timestamp? get lastMessageTimestamp;
  @override
  @MapTimestampConverter()
  Map<String, Timestamp> get lastReadAt;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatModelImplCopyWith<_$ChatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
