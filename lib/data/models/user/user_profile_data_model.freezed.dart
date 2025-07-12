// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfileDataModel _$UserProfileDataModelFromJson(Map<String, dynamic> json) {
  return _UserProfileDataModel.fromJson(json);
}

/// @nodoc
mixin _$UserProfileDataModel {
  String? get bloodType => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get lastDonationDate => throw _privateConstructorUsedError;
  int get donationCount => throw _privateConstructorUsedError;
  bool get isAvailableToDonate => throw _privateConstructorUsedError;
  String? get medicalInfo => throw _privateConstructorUsedError;
  UserGender get gender => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get birthDate => throw _privateConstructorUsedError;
  String? get activeRequestId => throw _privateConstructorUsedError;
  int get totalLivesSaved => throw _privateConstructorUsedError;
  List<String> get badges => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get nextAppointmentDate => throw _privateConstructorUsedError;
  String? get nextAppointmentLocation => throw _privateConstructorUsedError;
  @GeoPointConverter()
  GeoPoint? get location => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp? get lastLocationUpdate => throw _privateConstructorUsedError;
  String? get hospitalName => throw _privateConstructorUsedError;
  String? get hospitalAddress => throw _privateConstructorUsedError;
  String? get hospitalContact => throw _privateConstructorUsedError;
  bool get isHospitalVerified => throw _privateConstructorUsedError;
  String? get associatedDonationCenterId => throw _privateConstructorUsedError;

  /// Serializes this UserProfileDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileDataModelCopyWith<UserProfileDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileDataModelCopyWith<$Res> {
  factory $UserProfileDataModelCopyWith(UserProfileDataModel value,
          $Res Function(UserProfileDataModel) then) =
      _$UserProfileDataModelCopyWithImpl<$Res, UserProfileDataModel>;
  @useResult
  $Res call(
      {String? bloodType,
      @TimestampConverter() Timestamp? lastDonationDate,
      int donationCount,
      bool isAvailableToDonate,
      String? medicalInfo,
      UserGender gender,
      @TimestampConverter() Timestamp? birthDate,
      String? activeRequestId,
      int totalLivesSaved,
      List<String> badges,
      int level,
      int points,
      @TimestampConverter() Timestamp? nextAppointmentDate,
      String? nextAppointmentLocation,
      @GeoPointConverter() GeoPoint? location,
      @TimestampConverter() Timestamp? lastLocationUpdate,
      String? hospitalName,
      String? hospitalAddress,
      String? hospitalContact,
      bool isHospitalVerified,
      String? associatedDonationCenterId});
}

/// @nodoc
class _$UserProfileDataModelCopyWithImpl<$Res,
        $Val extends UserProfileDataModel>
    implements $UserProfileDataModelCopyWith<$Res> {
  _$UserProfileDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bloodType = freezed,
    Object? lastDonationDate = freezed,
    Object? donationCount = null,
    Object? isAvailableToDonate = null,
    Object? medicalInfo = freezed,
    Object? gender = null,
    Object? birthDate = freezed,
    Object? activeRequestId = freezed,
    Object? totalLivesSaved = null,
    Object? badges = null,
    Object? level = null,
    Object? points = null,
    Object? nextAppointmentDate = freezed,
    Object? nextAppointmentLocation = freezed,
    Object? location = freezed,
    Object? lastLocationUpdate = freezed,
    Object? hospitalName = freezed,
    Object? hospitalAddress = freezed,
    Object? hospitalContact = freezed,
    Object? isHospitalVerified = null,
    Object? associatedDonationCenterId = freezed,
  }) {
    return _then(_value.copyWith(
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      lastDonationDate: freezed == lastDonationDate
          ? _value.lastDonationDate
          : lastDonationDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      donationCount: null == donationCount
          ? _value.donationCount
          : donationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailableToDonate: null == isAvailableToDonate
          ? _value.isAvailableToDonate
          : isAvailableToDonate // ignore: cast_nullable_to_non_nullable
              as bool,
      medicalInfo: freezed == medicalInfo
          ? _value.medicalInfo
          : medicalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as UserGender,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      activeRequestId: freezed == activeRequestId
          ? _value.activeRequestId
          : activeRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalLivesSaved: null == totalLivesSaved
          ? _value.totalLivesSaved
          : totalLivesSaved // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      nextAppointmentDate: freezed == nextAppointmentDate
          ? _value.nextAppointmentDate
          : nextAppointmentDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      nextAppointmentLocation: freezed == nextAppointmentLocation
          ? _value.nextAppointmentLocation
          : nextAppointmentLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      lastLocationUpdate: freezed == lastLocationUpdate
          ? _value.lastLocationUpdate
          : lastLocationUpdate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      hospitalAddress: freezed == hospitalAddress
          ? _value.hospitalAddress
          : hospitalAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      hospitalContact: freezed == hospitalContact
          ? _value.hospitalContact
          : hospitalContact // ignore: cast_nullable_to_non_nullable
              as String?,
      isHospitalVerified: null == isHospitalVerified
          ? _value.isHospitalVerified
          : isHospitalVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      associatedDonationCenterId: freezed == associatedDonationCenterId
          ? _value.associatedDonationCenterId
          : associatedDonationCenterId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileDataModelImplCopyWith<$Res>
    implements $UserProfileDataModelCopyWith<$Res> {
  factory _$$UserProfileDataModelImplCopyWith(_$UserProfileDataModelImpl value,
          $Res Function(_$UserProfileDataModelImpl) then) =
      __$$UserProfileDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? bloodType,
      @TimestampConverter() Timestamp? lastDonationDate,
      int donationCount,
      bool isAvailableToDonate,
      String? medicalInfo,
      UserGender gender,
      @TimestampConverter() Timestamp? birthDate,
      String? activeRequestId,
      int totalLivesSaved,
      List<String> badges,
      int level,
      int points,
      @TimestampConverter() Timestamp? nextAppointmentDate,
      String? nextAppointmentLocation,
      @GeoPointConverter() GeoPoint? location,
      @TimestampConverter() Timestamp? lastLocationUpdate,
      String? hospitalName,
      String? hospitalAddress,
      String? hospitalContact,
      bool isHospitalVerified,
      String? associatedDonationCenterId});
}

/// @nodoc
class __$$UserProfileDataModelImplCopyWithImpl<$Res>
    extends _$UserProfileDataModelCopyWithImpl<$Res, _$UserProfileDataModelImpl>
    implements _$$UserProfileDataModelImplCopyWith<$Res> {
  __$$UserProfileDataModelImplCopyWithImpl(_$UserProfileDataModelImpl _value,
      $Res Function(_$UserProfileDataModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bloodType = freezed,
    Object? lastDonationDate = freezed,
    Object? donationCount = null,
    Object? isAvailableToDonate = null,
    Object? medicalInfo = freezed,
    Object? gender = null,
    Object? birthDate = freezed,
    Object? activeRequestId = freezed,
    Object? totalLivesSaved = null,
    Object? badges = null,
    Object? level = null,
    Object? points = null,
    Object? nextAppointmentDate = freezed,
    Object? nextAppointmentLocation = freezed,
    Object? location = freezed,
    Object? lastLocationUpdate = freezed,
    Object? hospitalName = freezed,
    Object? hospitalAddress = freezed,
    Object? hospitalContact = freezed,
    Object? isHospitalVerified = null,
    Object? associatedDonationCenterId = freezed,
  }) {
    return _then(_$UserProfileDataModelImpl(
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      lastDonationDate: freezed == lastDonationDate
          ? _value.lastDonationDate
          : lastDonationDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      donationCount: null == donationCount
          ? _value.donationCount
          : donationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailableToDonate: null == isAvailableToDonate
          ? _value.isAvailableToDonate
          : isAvailableToDonate // ignore: cast_nullable_to_non_nullable
              as bool,
      medicalInfo: freezed == medicalInfo
          ? _value.medicalInfo
          : medicalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as UserGender,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      activeRequestId: freezed == activeRequestId
          ? _value.activeRequestId
          : activeRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalLivesSaved: null == totalLivesSaved
          ? _value.totalLivesSaved
          : totalLivesSaved // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      nextAppointmentDate: freezed == nextAppointmentDate
          ? _value.nextAppointmentDate
          : nextAppointmentDate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      nextAppointmentLocation: freezed == nextAppointmentLocation
          ? _value.nextAppointmentLocation
          : nextAppointmentLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      lastLocationUpdate: freezed == lastLocationUpdate
          ? _value.lastLocationUpdate
          : lastLocationUpdate // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      hospitalAddress: freezed == hospitalAddress
          ? _value.hospitalAddress
          : hospitalAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      hospitalContact: freezed == hospitalContact
          ? _value.hospitalContact
          : hospitalContact // ignore: cast_nullable_to_non_nullable
              as String?,
      isHospitalVerified: null == isHospitalVerified
          ? _value.isHospitalVerified
          : isHospitalVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      associatedDonationCenterId: freezed == associatedDonationCenterId
          ? _value.associatedDonationCenterId
          : associatedDonationCenterId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileDataModelImpl extends _UserProfileDataModel {
  const _$UserProfileDataModelImpl(
      {this.bloodType,
      @TimestampConverter() this.lastDonationDate,
      this.donationCount = 0,
      this.isAvailableToDonate = true,
      this.medicalInfo,
      this.gender = UserGender.unknown,
      @TimestampConverter() this.birthDate,
      this.activeRequestId,
      this.totalLivesSaved = 0,
      final List<String> badges = const <String>[],
      this.level = 1,
      this.points = 0,
      @TimestampConverter() this.nextAppointmentDate,
      this.nextAppointmentLocation,
      @GeoPointConverter() this.location,
      @TimestampConverter() this.lastLocationUpdate,
      this.hospitalName,
      this.hospitalAddress,
      this.hospitalContact,
      this.isHospitalVerified = false,
      this.associatedDonationCenterId})
      : _badges = badges,
        super._();

  factory _$UserProfileDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileDataModelImplFromJson(json);

  @override
  final String? bloodType;
  @override
  @TimestampConverter()
  final Timestamp? lastDonationDate;
  @override
  @JsonKey()
  final int donationCount;
  @override
  @JsonKey()
  final bool isAvailableToDonate;
  @override
  final String? medicalInfo;
  @override
  @JsonKey()
  final UserGender gender;
  @override
  @TimestampConverter()
  final Timestamp? birthDate;
  @override
  final String? activeRequestId;
  @override
  @JsonKey()
  final int totalLivesSaved;
  final List<String> _badges;
  @override
  @JsonKey()
  List<String> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int points;
  @override
  @TimestampConverter()
  final Timestamp? nextAppointmentDate;
  @override
  final String? nextAppointmentLocation;
  @override
  @GeoPointConverter()
  final GeoPoint? location;
  @override
  @TimestampConverter()
  final Timestamp? lastLocationUpdate;
  @override
  final String? hospitalName;
  @override
  final String? hospitalAddress;
  @override
  final String? hospitalContact;
  @override
  @JsonKey()
  final bool isHospitalVerified;
  @override
  final String? associatedDonationCenterId;

  @override
  String toString() {
    return 'UserProfileDataModel(bloodType: $bloodType, lastDonationDate: $lastDonationDate, donationCount: $donationCount, isAvailableToDonate: $isAvailableToDonate, medicalInfo: $medicalInfo, gender: $gender, birthDate: $birthDate, activeRequestId: $activeRequestId, totalLivesSaved: $totalLivesSaved, badges: $badges, level: $level, points: $points, nextAppointmentDate: $nextAppointmentDate, nextAppointmentLocation: $nextAppointmentLocation, location: $location, lastLocationUpdate: $lastLocationUpdate, hospitalName: $hospitalName, hospitalAddress: $hospitalAddress, hospitalContact: $hospitalContact, isHospitalVerified: $isHospitalVerified, associatedDonationCenterId: $associatedDonationCenterId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileDataModelImpl &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            (identical(other.lastDonationDate, lastDonationDate) ||
                other.lastDonationDate == lastDonationDate) &&
            (identical(other.donationCount, donationCount) ||
                other.donationCount == donationCount) &&
            (identical(other.isAvailableToDonate, isAvailableToDonate) ||
                other.isAvailableToDonate == isAvailableToDonate) &&
            (identical(other.medicalInfo, medicalInfo) ||
                other.medicalInfo == medicalInfo) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.activeRequestId, activeRequestId) ||
                other.activeRequestId == activeRequestId) &&
            (identical(other.totalLivesSaved, totalLivesSaved) ||
                other.totalLivesSaved == totalLivesSaved) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.nextAppointmentDate, nextAppointmentDate) ||
                other.nextAppointmentDate == nextAppointmentDate) &&
            (identical(
                    other.nextAppointmentLocation, nextAppointmentLocation) ||
                other.nextAppointmentLocation == nextAppointmentLocation) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastLocationUpdate, lastLocationUpdate) ||
                other.lastLocationUpdate == lastLocationUpdate) &&
            (identical(other.hospitalName, hospitalName) ||
                other.hospitalName == hospitalName) &&
            (identical(other.hospitalAddress, hospitalAddress) ||
                other.hospitalAddress == hospitalAddress) &&
            (identical(other.hospitalContact, hospitalContact) ||
                other.hospitalContact == hospitalContact) &&
            (identical(other.isHospitalVerified, isHospitalVerified) ||
                other.isHospitalVerified == isHospitalVerified) &&
            (identical(other.associatedDonationCenterId,
                    associatedDonationCenterId) ||
                other.associatedDonationCenterId ==
                    associatedDonationCenterId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        bloodType,
        lastDonationDate,
        donationCount,
        isAvailableToDonate,
        medicalInfo,
        gender,
        birthDate,
        activeRequestId,
        totalLivesSaved,
        const DeepCollectionEquality().hash(_badges),
        level,
        points,
        nextAppointmentDate,
        nextAppointmentLocation,
        location,
        lastLocationUpdate,
        hospitalName,
        hospitalAddress,
        hospitalContact,
        isHospitalVerified,
        associatedDonationCenterId
      ]);

  /// Create a copy of UserProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileDataModelImplCopyWith<_$UserProfileDataModelImpl>
      get copyWith =>
          __$$UserProfileDataModelImplCopyWithImpl<_$UserProfileDataModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileDataModelImplToJson(
      this,
    );
  }
}

abstract class _UserProfileDataModel extends UserProfileDataModel {
  const factory _UserProfileDataModel(
      {final String? bloodType,
      @TimestampConverter() final Timestamp? lastDonationDate,
      final int donationCount,
      final bool isAvailableToDonate,
      final String? medicalInfo,
      final UserGender gender,
      @TimestampConverter() final Timestamp? birthDate,
      final String? activeRequestId,
      final int totalLivesSaved,
      final List<String> badges,
      final int level,
      final int points,
      @TimestampConverter() final Timestamp? nextAppointmentDate,
      final String? nextAppointmentLocation,
      @GeoPointConverter() final GeoPoint? location,
      @TimestampConverter() final Timestamp? lastLocationUpdate,
      final String? hospitalName,
      final String? hospitalAddress,
      final String? hospitalContact,
      final bool isHospitalVerified,
      final String? associatedDonationCenterId}) = _$UserProfileDataModelImpl;
  const _UserProfileDataModel._() : super._();

  factory _UserProfileDataModel.fromJson(Map<String, dynamic> json) =
      _$UserProfileDataModelImpl.fromJson;

  @override
  String? get bloodType;
  @override
  @TimestampConverter()
  Timestamp? get lastDonationDate;
  @override
  int get donationCount;
  @override
  bool get isAvailableToDonate;
  @override
  String? get medicalInfo;
  @override
  UserGender get gender;
  @override
  @TimestampConverter()
  Timestamp? get birthDate;
  @override
  String? get activeRequestId;
  @override
  int get totalLivesSaved;
  @override
  List<String> get badges;
  @override
  int get level;
  @override
  int get points;
  @override
  @TimestampConverter()
  Timestamp? get nextAppointmentDate;
  @override
  String? get nextAppointmentLocation;
  @override
  @GeoPointConverter()
  GeoPoint? get location;
  @override
  @TimestampConverter()
  Timestamp? get lastLocationUpdate;
  @override
  String? get hospitalName;
  @override
  String? get hospitalAddress;
  @override
  String? get hospitalContact;
  @override
  bool get isHospitalVerified;
  @override
  String? get associatedDonationCenterId;

  /// Create a copy of UserProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileDataModelImplCopyWith<_$UserProfileDataModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
