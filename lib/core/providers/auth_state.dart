// lib/core/providers/auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/data/models/json_converters.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @UserModelConverter() UserModel? user,
    String? errorMessage,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);
}
