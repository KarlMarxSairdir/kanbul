// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) {
  return _UserSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$UserSettingsModel {
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  String get privacyLevel =>
      throw _privateConstructorUsedError; // 'public', 'friends_only', 'private'
  bool get locationSharingEnabled =>
      throw _privateConstructorUsedError; // İzin akışının çalışması için varsayılan değer false olmalı
  bool get locationPermissionAsked => throw _privateConstructorUsedError;

  /// Serializes this UserSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsModelCopyWith<UserSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsModelCopyWith<$Res> {
  factory $UserSettingsModelCopyWith(
          UserSettingsModel value, $Res Function(UserSettingsModel) then) =
      _$UserSettingsModelCopyWithImpl<$Res, UserSettingsModel>;
  @useResult
  $Res call(
      {bool notificationsEnabled,
      String privacyLevel,
      bool locationSharingEnabled,
      bool locationPermissionAsked});
}

/// @nodoc
class _$UserSettingsModelCopyWithImpl<$Res, $Val extends UserSettingsModel>
    implements $UserSettingsModelCopyWith<$Res> {
  _$UserSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationsEnabled = null,
    Object? privacyLevel = null,
    Object? locationSharingEnabled = null,
    Object? locationPermissionAsked = null,
  }) {
    return _then(_value.copyWith(
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as String,
      locationSharingEnabled: null == locationSharingEnabled
          ? _value.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      locationPermissionAsked: null == locationPermissionAsked
          ? _value.locationPermissionAsked
          : locationPermissionAsked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSettingsModelImplCopyWith<$Res>
    implements $UserSettingsModelCopyWith<$Res> {
  factory _$$UserSettingsModelImplCopyWith(_$UserSettingsModelImpl value,
          $Res Function(_$UserSettingsModelImpl) then) =
      __$$UserSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool notificationsEnabled,
      String privacyLevel,
      bool locationSharingEnabled,
      bool locationPermissionAsked});
}

/// @nodoc
class __$$UserSettingsModelImplCopyWithImpl<$Res>
    extends _$UserSettingsModelCopyWithImpl<$Res, _$UserSettingsModelImpl>
    implements _$$UserSettingsModelImplCopyWith<$Res> {
  __$$UserSettingsModelImplCopyWithImpl(_$UserSettingsModelImpl _value,
      $Res Function(_$UserSettingsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationsEnabled = null,
    Object? privacyLevel = null,
    Object? locationSharingEnabled = null,
    Object? locationPermissionAsked = null,
  }) {
    return _then(_$UserSettingsModelImpl(
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as String,
      locationSharingEnabled: null == locationSharingEnabled
          ? _value.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      locationPermissionAsked: null == locationPermissionAsked
          ? _value.locationPermissionAsked
          : locationPermissionAsked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsModelImpl implements _UserSettingsModel {
  const _$UserSettingsModelImpl(
      {this.notificationsEnabled = true,
      this.privacyLevel = 'public',
      this.locationSharingEnabled = false,
      this.locationPermissionAsked = false});

  factory _$UserSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsModelImplFromJson(json);

  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final String privacyLevel;
// 'public', 'friends_only', 'private'
  @override
  @JsonKey()
  final bool locationSharingEnabled;
// İzin akışının çalışması için varsayılan değer false olmalı
  @override
  @JsonKey()
  final bool locationPermissionAsked;

  @override
  String toString() {
    return 'UserSettingsModel(notificationsEnabled: $notificationsEnabled, privacyLevel: $privacyLevel, locationSharingEnabled: $locationSharingEnabled, locationPermissionAsked: $locationPermissionAsked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsModelImpl &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.privacyLevel, privacyLevel) ||
                other.privacyLevel == privacyLevel) &&
            (identical(other.locationSharingEnabled, locationSharingEnabled) ||
                other.locationSharingEnabled == locationSharingEnabled) &&
            (identical(
                    other.locationPermissionAsked, locationPermissionAsked) ||
                other.locationPermissionAsked == locationPermissionAsked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notificationsEnabled,
      privacyLevel, locationSharingEnabled, locationPermissionAsked);

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      __$$UserSettingsModelImplCopyWithImpl<_$UserSettingsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsModelImplToJson(
      this,
    );
  }
}

abstract class _UserSettingsModel implements UserSettingsModel {
  const factory _UserSettingsModel(
      {final bool notificationsEnabled,
      final String privacyLevel,
      final bool locationSharingEnabled,
      final bool locationPermissionAsked}) = _$UserSettingsModelImpl;

  factory _UserSettingsModel.fromJson(Map<String, dynamic> json) =
      _$UserSettingsModelImpl.fromJson;

  @override
  bool get notificationsEnabled;
  @override
  String get privacyLevel; // 'public', 'friends_only', 'private'
  @override
  bool
      get locationSharingEnabled; // İzin akışının çalışması için varsayılan değer false olmalı
  @override
  bool get locationPermissionAsked;

  /// Create a copy of UserSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsModelImplCopyWith<_$UserSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
