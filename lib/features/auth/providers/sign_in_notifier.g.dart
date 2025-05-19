// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$signInNotifierHash() => r'58d9d9b37a0b8c0ffb05b680188b104a15e3cf18';

/// Giriş işlemi için özel notifier sınıfı.
/// AsyncNotifier kullanarak loading/error/data durumlarını yönetir.
///
/// Copied from [SignInNotifier].
@ProviderFor(SignInNotifier)
final signInNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SignInNotifier, void>.internal(
  SignInNotifier.new,
  name: r'signInNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignInNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
