// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blood_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BloodRequest _$BloodRequestFromJson(Map<String, dynamic> json) {
  return _BloodRequest.fromJson(json);
}

/// @nodoc
mixin _$BloodRequest {
// ID artık JSON'dan okunabilecek
  String get id =>
      throw _privateConstructorUsedError; // fromSnapshot'ta eklendiği için required
  String get creatorId => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  String get creatorRole => throw _privateConstructorUsedError;
  String get bloodType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get hospitalName => throw _privateConstructorUsedError;
  int get unitsNeeded => throw _privateConstructorUsedError;
  int get urgencyLevel =>
      throw _privateConstructorUsedError; // Nullable alanlar
  @GeoPointConverter()
  GeoPoint? get location => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get updatedAt => throw _privateConstructorUsedError;
  String? get patientInfo => throw _privateConstructorUsedError;
  String? get contactPhone =>
      throw _privateConstructorUsedError; // Gerekli alanlar (varsayılan değerlerle)
  String get status => throw _privateConstructorUsedError;
  int get responseCount => throw _privateConstructorUsedError;
  List<String> get acceptedDonorIds => throw _privateConstructorUsedError;

  /// Serializes this BloodRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BloodRequestCopyWith<BloodRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BloodRequestCopyWith<$Res> {
  factory $BloodRequestCopyWith(
          BloodRequest value, $Res Function(BloodRequest) then) =
      _$BloodRequestCopyWithImpl<$Res, BloodRequest>;
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String creatorName,
      String creatorRole,
      String bloodType,
      String title,
      String description,
      String hospitalName,
      int unitsNeeded,
      int urgencyLevel,
      @GeoPointConverter() GeoPoint? location,
      @TimestampConverter() Timestamp? createdAt,
      @TimestampConverter() Timestamp? updatedAt,
      String? patientInfo,
      String? contactPhone,
      String status,
      int responseCount,
      List<String> acceptedDonorIds});
}

/// @nodoc
class _$BloodRequestCopyWithImpl<$Res, $Val extends BloodRequest>
    implements $BloodRequestCopyWith<$Res> {
  _$BloodRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? creatorRole = null,
    Object? bloodType = null,
    Object? title = null,
    Object? description = null,
    Object? hospitalName = null,
    Object? unitsNeeded = null,
    Object? urgencyLevel = null,
    Object? location = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? patientInfo = freezed,
    Object? contactPhone = freezed,
    Object? status = null,
    Object? responseCount = null,
    Object? acceptedDonorIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorRole: null == creatorRole
          ? _value.creatorRole
          : creatorRole // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: null == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      hospitalName: null == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String,
      unitsNeeded: null == unitsNeeded
          ? _value.unitsNeeded
          : unitsNeeded // ignore: cast_nullable_to_non_nullable
              as int,
      urgencyLevel: null == urgencyLevel
          ? _value.urgencyLevel
          : urgencyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      patientInfo: freezed == patientInfo
          ? _value.patientInfo
          : patientInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      responseCount: null == responseCount
          ? _value.responseCount
          : responseCount // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedDonorIds: null == acceptedDonorIds
          ? _value.acceptedDonorIds
          : acceptedDonorIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BloodRequestImplCopyWith<$Res>
    implements $BloodRequestCopyWith<$Res> {
  factory _$$BloodRequestImplCopyWith(
          _$BloodRequestImpl value, $Res Function(_$BloodRequestImpl) then) =
      __$$BloodRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String creatorName,
      String creatorRole,
      String bloodType,
      String title,
      String description,
      String hospitalName,
      int unitsNeeded,
      int urgencyLevel,
      @GeoPointConverter() GeoPoint? location,
      @TimestampConverter() Timestamp? createdAt,
      @TimestampConverter() Timestamp? updatedAt,
      String? patientInfo,
      String? contactPhone,
      String status,
      int responseCount,
      List<String> acceptedDonorIds});
}

/// @nodoc
class __$$BloodRequestImplCopyWithImpl<$Res>
    extends _$BloodRequestCopyWithImpl<$Res, _$BloodRequestImpl>
    implements _$$BloodRequestImplCopyWith<$Res> {
  __$$BloodRequestImplCopyWithImpl(
      _$BloodRequestImpl _value, $Res Function(_$BloodRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? creatorRole = null,
    Object? bloodType = null,
    Object? title = null,
    Object? description = null,
    Object? hospitalName = null,
    Object? unitsNeeded = null,
    Object? urgencyLevel = null,
    Object? location = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? patientInfo = freezed,
    Object? contactPhone = freezed,
    Object? status = null,
    Object? responseCount = null,
    Object? acceptedDonorIds = null,
  }) {
    return _then(_$BloodRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorRole: null == creatorRole
          ? _value.creatorRole
          : creatorRole // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: null == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      hospitalName: null == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String,
      unitsNeeded: null == unitsNeeded
          ? _value.unitsNeeded
          : unitsNeeded // ignore: cast_nullable_to_non_nullable
              as int,
      urgencyLevel: null == urgencyLevel
          ? _value.urgencyLevel
          : urgencyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      patientInfo: freezed == patientInfo
          ? _value.patientInfo
          : patientInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      responseCount: null == responseCount
          ? _value.responseCount
          : responseCount // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedDonorIds: null == acceptedDonorIds
          ? _value._acceptedDonorIds
          : acceptedDonorIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BloodRequestImpl extends _BloodRequest {
  const _$BloodRequestImpl(
      {required this.id,
      required this.creatorId,
      required this.creatorName,
      required this.creatorRole,
      required this.bloodType,
      required this.title,
      required this.description,
      required this.hospitalName,
      required this.unitsNeeded,
      required this.urgencyLevel,
      @GeoPointConverter() this.location,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt,
      this.patientInfo,
      this.contactPhone,
      this.status = 'active',
      this.responseCount = 0,
      final List<String> acceptedDonorIds = const []})
      : _acceptedDonorIds = acceptedDonorIds,
        super._();

  factory _$BloodRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BloodRequestImplFromJson(json);

// ID artık JSON'dan okunabilecek
  @override
  final String id;
// fromSnapshot'ta eklendiği için required
  @override
  final String creatorId;
  @override
  final String creatorName;
  @override
  final String creatorRole;
  @override
  final String bloodType;
  @override
  final String title;
  @override
  final String description;
  @override
  final String hospitalName;
  @override
  final int unitsNeeded;
  @override
  final int urgencyLevel;
// Nullable alanlar
  @override
  @GeoPointConverter()
  final GeoPoint? location;
  @override
  @TimestampConverter()
  final Timestamp? createdAt;
  @override
  @TimestampConverter()
  final Timestamp? updatedAt;
  @override
  final String? patientInfo;
  @override
  final String? contactPhone;
// Gerekli alanlar (varsayılan değerlerle)
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final int responseCount;
  final List<String> _acceptedDonorIds;
  @override
  @JsonKey()
  List<String> get acceptedDonorIds {
    if (_acceptedDonorIds is EqualUnmodifiableListView)
      return _acceptedDonorIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acceptedDonorIds);
  }

  @override
  String toString() {
    return 'BloodRequest(id: $id, creatorId: $creatorId, creatorName: $creatorName, creatorRole: $creatorRole, bloodType: $bloodType, title: $title, description: $description, hospitalName: $hospitalName, unitsNeeded: $unitsNeeded, urgencyLevel: $urgencyLevel, location: $location, createdAt: $createdAt, updatedAt: $updatedAt, patientInfo: $patientInfo, contactPhone: $contactPhone, status: $status, responseCount: $responseCount, acceptedDonorIds: $acceptedDonorIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BloodRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.creatorRole, creatorRole) ||
                other.creatorRole == creatorRole) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.hospitalName, hospitalName) ||
                other.hospitalName == hospitalName) &&
            (identical(other.unitsNeeded, unitsNeeded) ||
                other.unitsNeeded == unitsNeeded) &&
            (identical(other.urgencyLevel, urgencyLevel) ||
                other.urgencyLevel == urgencyLevel) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.patientInfo, patientInfo) ||
                other.patientInfo == patientInfo) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.responseCount, responseCount) ||
                other.responseCount == responseCount) &&
            const DeepCollectionEquality()
                .equals(other._acceptedDonorIds, _acceptedDonorIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      creatorId,
      creatorName,
      creatorRole,
      bloodType,
      title,
      description,
      hospitalName,
      unitsNeeded,
      urgencyLevel,
      location,
      createdAt,
      updatedAt,
      patientInfo,
      contactPhone,
      status,
      responseCount,
      const DeepCollectionEquality().hash(_acceptedDonorIds));

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BloodRequestImplCopyWith<_$BloodRequestImpl> get copyWith =>
      __$$BloodRequestImplCopyWithImpl<_$BloodRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BloodRequestImplToJson(
      this,
    );
  }
}

abstract class _BloodRequest extends BloodRequest {
  const factory _BloodRequest(
      {required final String id,
      required final String creatorId,
      required final String creatorName,
      required final String creatorRole,
      required final String bloodType,
      required final String title,
      required final String description,
      required final String hospitalName,
      required final int unitsNeeded,
      required final int urgencyLevel,
      @GeoPointConverter() final GeoPoint? location,
      @TimestampConverter() final Timestamp? createdAt,
      @TimestampConverter() final Timestamp? updatedAt,
      final String? patientInfo,
      final String? contactPhone,
      final String status,
      final int responseCount,
      final List<String> acceptedDonorIds}) = _$BloodRequestImpl;
  const _BloodRequest._() : super._();

  factory _BloodRequest.fromJson(Map<String, dynamic> json) =
      _$BloodRequestImpl.fromJson;

// ID artık JSON'dan okunabilecek
  @override
  String get id; // fromSnapshot'ta eklendiği için required
  @override
  String get creatorId;
  @override
  String get creatorName;
  @override
  String get creatorRole;
  @override
  String get bloodType;
  @override
  String get title;
  @override
  String get description;
  @override
  String get hospitalName;
  @override
  int get unitsNeeded;
  @override
  int get urgencyLevel; // Nullable alanlar
  @override
  @GeoPointConverter()
  GeoPoint? get location;
  @override
  @TimestampConverter()
  Timestamp? get createdAt;
  @override
  @TimestampConverter()
  Timestamp? get updatedAt;
  @override
  String? get patientInfo;
  @override
  String? get contactPhone; // Gerekli alanlar (varsayılan değerlerle)
  @override
  String get status;
  @override
  int get responseCount;
  @override
  List<String> get acceptedDonorIds;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BloodRequestImplCopyWith<_$BloodRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
