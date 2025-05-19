// lib/data/models/user/user_settings_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings_model.freezed.dart';
part 'user_settings_model.g.dart';

/// Kullanıcı ayarlarını tutan model sınıfı
@freezed
class UserSettingsModel with _$UserSettingsModel {
  const factory UserSettingsModel({
    @Default(true) bool notificationsEnabled,
    @Default('public')
    String privacyLevel, // 'public', 'friends_only', 'private'
    @Default(false)
    bool
    locationSharingEnabled, // İzin akışının çalışması için varsayılan değer false olmalı
    @Default(false)
    bool
    locationPermissionAsked, // İzin istenip istenmediğini izlemek için yeni alan
  }) = _UserSettingsModel;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);

  /// Null veya hatalı JSON için güvenli dönüşüm sağlar
  static UserSettingsModel fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return const UserSettingsModel();
    try {
      return UserSettingsModel.fromJson(json);
    } catch (e) {
      return const UserSettingsModel();
    }
  }
}
