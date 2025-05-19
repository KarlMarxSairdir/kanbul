// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_request_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bloodRequestRepositoryHash() =>
    r'33bb2d5e65767b4773d7348cae0dd88756bed049';

/// See also [bloodRequestRepository].
@ProviderFor(bloodRequestRepository)
final bloodRequestRepositoryProvider =
    AutoDisposeProvider<IBloodRequestRepository>.internal(
  bloodRequestRepository,
  name: r'bloodRequestRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bloodRequestRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BloodRequestRepositoryRef
    = AutoDisposeProviderRef<IBloodRequestRepository>;
String _$allActiveBloodRequestsHash() =>
    r'b4502a7de0ebed031f99ad412ebeeb0328959be8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [allActiveBloodRequests].
@ProviderFor(allActiveBloodRequests)
const allActiveBloodRequestsProvider = AllActiveBloodRequestsFamily();

/// See also [allActiveBloodRequests].
class AllActiveBloodRequestsFamily
    extends Family<AsyncValue<List<BloodRequest>>> {
  /// See also [allActiveBloodRequests].
  const AllActiveBloodRequestsFamily();

  /// See also [allActiveBloodRequests].
  AllActiveBloodRequestsProvider call({
    int limit = 300,
  }) {
    return AllActiveBloodRequestsProvider(
      limit: limit,
    );
  }

  @override
  AllActiveBloodRequestsProvider getProviderOverride(
    covariant AllActiveBloodRequestsProvider provider,
  ) {
    return call(
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allActiveBloodRequestsProvider';
}

/// See also [allActiveBloodRequests].
class AllActiveBloodRequestsProvider
    extends AutoDisposeStreamProvider<List<BloodRequest>> {
  /// See also [allActiveBloodRequests].
  AllActiveBloodRequestsProvider({
    int limit = 300,
  }) : this._internal(
          (ref) => allActiveBloodRequests(
            ref as AllActiveBloodRequestsRef,
            limit: limit,
          ),
          from: allActiveBloodRequestsProvider,
          name: r'allActiveBloodRequestsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allActiveBloodRequestsHash,
          dependencies: AllActiveBloodRequestsFamily._dependencies,
          allTransitiveDependencies:
              AllActiveBloodRequestsFamily._allTransitiveDependencies,
          limit: limit,
        );

  AllActiveBloodRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    Stream<List<BloodRequest>> Function(AllActiveBloodRequestsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllActiveBloodRequestsProvider._internal(
        (ref) => create(ref as AllActiveBloodRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BloodRequest>> createElement() {
    return _AllActiveBloodRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllActiveBloodRequestsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllActiveBloodRequestsRef
    on AutoDisposeStreamProviderRef<List<BloodRequest>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _AllActiveBloodRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<BloodRequest>>
    with AllActiveBloodRequestsRef {
  _AllActiveBloodRequestsProviderElement(super.provider);

  @override
  int get limit => (origin as AllActiveBloodRequestsProvider).limit;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
