// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$passwordResetNotifierHash() =>
    r'9d123725b7fb1fcf5cf98ee634ed3404ea5f8eae';

/// Şifre sıfırlama işlemi için özel notifier sınıfı.
/// AsyncNotifier kullanarak loading/error/data durumlarını yönetir.
///
/// Copied from [PasswordResetNotifier].
@ProviderFor(PasswordResetNotifier)
final passwordResetNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PasswordResetNotifier, void>.internal(
  PasswordResetNotifier.new,
  name: r'passwordResetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$passwordResetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PasswordResetNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
