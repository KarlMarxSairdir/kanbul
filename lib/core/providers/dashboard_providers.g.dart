// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbyBloodRequestsCountHash() =>
    r'1d2a32fcd9196bb8bcb984af6a7577f6d297de3e';

/// Kullanıcı konumuna göre yakındaki kan talepleri sayısı
/// Dinamik olarak hesaplanır
///
/// Copied from [nearbyBloodRequestsCount].
@ProviderFor(nearbyBloodRequestsCount)
final nearbyBloodRequestsCountProvider =
    AutoDisposeProvider<AsyncValue<int>>.internal(
  nearbyBloodRequestsCount,
  name: r'nearbyBloodRequestsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyBloodRequestsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NearbyBloodRequestsCountRef = AutoDisposeProviderRef<AsyncValue<int>>;
String _$userRoleDisplayHash() => r'b545d145ec803af73246428cb391fc166612b325';

/// Kullanıcı rolüne göre gösteri state'i
///
/// Copied from [userRoleDisplay].
@ProviderFor(userRoleDisplay)
final userRoleDisplayProvider = AutoDisposeProvider<UserRole?>.internal(
  userRoleDisplay,
  name: r'userRoleDisplayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRoleDisplayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRoleDisplayRef = AutoDisposeProviderRef<UserRole?>;
String _$locationStateHash() => r'6b23ad9d6c53daee2e52ed79065cc26a9fe43d6f';

/// Konum durumu
///
/// Copied from [locationState].
@ProviderFor(locationState)
final locationStateProvider =
    AutoDisposeProvider<AsyncValue<Position?>>.internal(
  locationState,
  name: r'locationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationStateRef = AutoDisposeProviderRef<AsyncValue<Position?>>;
String _$selectedDashboardSegmentHash() =>
    r'be7aa16c490edfa1a89fcfc3871956ac87e0a426';

/// See also [SelectedDashboardSegment].
@ProviderFor(SelectedDashboardSegment)
final selectedDashboardSegmentProvider =
    AutoDisposeNotifierProvider<SelectedDashboardSegment, int>.internal(
  SelectedDashboardSegment.new,
  name: r'selectedDashboardSegmentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedDashboardSegmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDashboardSegment = AutoDisposeNotifier<int>;
String _$dashboardRefreshHash() => r'8c4e16ece58e6c06e8dda14c9a886748db32c094';

/// See also [DashboardRefresh].
@ProviderFor(DashboardRefresh)
final dashboardRefreshProvider =
    AutoDisposeAsyncNotifierProvider<DashboardRefresh, void>.internal(
  DashboardRefresh.new,
  name: r'dashboardRefreshProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardRefreshHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DashboardRefresh = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
