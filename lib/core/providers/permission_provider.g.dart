// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$permissionCheckHash() => r'fc8742cdec5dbc39a88a2e0910aa978bf7133871';

/// İzin durumunu kontrol eden provider - Hem kullanıcının "kullanım kabul ettiği" hem de gerçek konum iznini kontrol eder
///
/// Copied from [permissionCheck].
@ProviderFor(permissionCheck)
final permissionCheckProvider = AutoDisposeFutureProvider<bool>.internal(
  permissionCheck,
  name: r'permissionCheckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionCheckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PermissionCheckRef = AutoDisposeFutureProviderRef<bool>;
String _$locationPermissionStatusHash() =>
    r'fe9f116acb0a30004ce5c7fcb68b1f9e13e58615';

/// Gerçek konum izni durumunu kontrol eden provider
///
/// Copied from [locationPermissionStatus].
@ProviderFor(locationPermissionStatus)
final locationPermissionStatusProvider =
    AutoDisposeFutureProvider<LocationPermissionStatus>.internal(
  locationPermissionStatus,
  name: r'locationPermissionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationPermissionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationPermissionStatusRef
    = AutoDisposeFutureProviderRef<LocationPermissionStatus>;
String _$requestLocationPermissionHash() =>
    r'ca2561834485ef7108aec8087e8d53e48fa87780';

/// İzin talep fonksiyonu - direkt permission_handler'ı kullanır
///
/// Copied from [requestLocationPermission].
@ProviderFor(requestLocationPermission)
final requestLocationPermissionProvider =
    AutoDisposeFutureProvider<LocationPermissionStatus>.internal(
  requestLocationPermission,
  name: r'requestLocationPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requestLocationPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequestLocationPermissionRef
    = AutoDisposeFutureProviderRef<LocationPermissionStatus>;
String _$permissionStatusHash() => r'9d67dada250a2ad74e99c198421c69777eda6afd';

/// İzin durumunu güncelleyen method provider
///
/// Copied from [PermissionStatus].
@ProviderFor(PermissionStatus)
final permissionStatusProvider =
    AutoDisposeNotifierProvider<PermissionStatus, bool>.internal(
  PermissionStatus.new,
  name: r'permissionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PermissionStatus = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
