// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_requests_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRequestsByStatusHash() =>
    r'c14872cedaa368230e628ddffb8336b5197e2b36';

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

/// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
/// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
///
/// Copied from [userRequestsByStatus].
@ProviderFor(userRequestsByStatus)
const userRequestsByStatusProvider = UserRequestsByStatusFamily();

/// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
/// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
///
/// Copied from [userRequestsByStatus].
class UserRequestsByStatusFamily
    extends Family<AsyncValue<List<BloodRequest>>> {
  /// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
  /// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
  ///
  /// Copied from [userRequestsByStatus].
  const UserRequestsByStatusFamily();

  /// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
  /// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
  ///
  /// Copied from [userRequestsByStatus].
  UserRequestsByStatusProvider call({
    required String userId,
    required String status,
  }) {
    return UserRequestsByStatusProvider(
      userId: userId,
      status: status,
    );
  }

  @override
  UserRequestsByStatusProvider getProviderOverride(
    covariant UserRequestsByStatusProvider provider,
  ) {
    return call(
      userId: provider.userId,
      status: provider.status,
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
  String? get name => r'userRequestsByStatusProvider';
}

/// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
/// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
///
/// Copied from [userRequestsByStatus].
class UserRequestsByStatusProvider extends StreamProvider<List<BloodRequest>> {
  /// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
  /// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
  ///
  /// Copied from [userRequestsByStatus].
  UserRequestsByStatusProvider({
    required String userId,
    required String status,
  }) : this._internal(
          (ref) => userRequestsByStatus(
            ref as UserRequestsByStatusRef,
            userId: userId,
            status: status,
          ),
          from: userRequestsByStatusProvider,
          name: r'userRequestsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userRequestsByStatusHash,
          dependencies: UserRequestsByStatusFamily._dependencies,
          allTransitiveDependencies:
              UserRequestsByStatusFamily._allTransitiveDependencies,
          userId: userId,
          status: status,
        );

  UserRequestsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.status,
  }) : super.internal();

  final String userId;
  final String status;

  @override
  Override overrideWith(
    Stream<List<BloodRequest>> Function(UserRequestsByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserRequestsByStatusProvider._internal(
        (ref) => create(ref as UserRequestsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        status: status,
      ),
    );
  }

  @override
  StreamProviderElement<List<BloodRequest>> createElement() {
    return _UserRequestsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRequestsByStatusProvider &&
        other.userId == userId &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserRequestsByStatusRef on StreamProviderRef<List<BloodRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `status` of this provider.
  String get status;
}

class _UserRequestsByStatusProviderElement
    extends StreamProviderElement<List<BloodRequest>>
    with UserRequestsByStatusRef {
  _UserRequestsByStatusProviderElement(super.provider);

  @override
  String get userId => (origin as UserRequestsByStatusProvider).userId;
  @override
  String get status => (origin as UserRequestsByStatusProvider).status;
}

String _$userActiveRequestsHash() =>
    r'33e3a4f71f8136ae3b9b58a0e479621b0dacd1f2';

/// Kullanıcının aktif (status=active) taleplerini izleyen provider
///
/// Copied from [userActiveRequests].
@ProviderFor(userActiveRequests)
const userActiveRequestsProvider = UserActiveRequestsFamily();

/// Kullanıcının aktif (status=active) taleplerini izleyen provider
///
/// Copied from [userActiveRequests].
class UserActiveRequestsFamily extends Family<AsyncValue<List<BloodRequest>>> {
  /// Kullanıcının aktif (status=active) taleplerini izleyen provider
  ///
  /// Copied from [userActiveRequests].
  const UserActiveRequestsFamily();

  /// Kullanıcının aktif (status=active) taleplerini izleyen provider
  ///
  /// Copied from [userActiveRequests].
  UserActiveRequestsProvider call(
    String userId,
  ) {
    return UserActiveRequestsProvider(
      userId,
    );
  }

  @override
  UserActiveRequestsProvider getProviderOverride(
    covariant UserActiveRequestsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userActiveRequestsProvider';
}

/// Kullanıcının aktif (status=active) taleplerini izleyen provider
///
/// Copied from [userActiveRequests].
class UserActiveRequestsProvider
    extends AutoDisposeStreamProvider<List<BloodRequest>> {
  /// Kullanıcının aktif (status=active) taleplerini izleyen provider
  ///
  /// Copied from [userActiveRequests].
  UserActiveRequestsProvider(
    String userId,
  ) : this._internal(
          (ref) => userActiveRequests(
            ref as UserActiveRequestsRef,
            userId,
          ),
          from: userActiveRequestsProvider,
          name: r'userActiveRequestsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userActiveRequestsHash,
          dependencies: UserActiveRequestsFamily._dependencies,
          allTransitiveDependencies:
              UserActiveRequestsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserActiveRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<BloodRequest>> Function(UserActiveRequestsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserActiveRequestsProvider._internal(
        (ref) => create(ref as UserActiveRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BloodRequest>> createElement() {
    return _UserActiveRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserActiveRequestsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserActiveRequestsRef
    on AutoDisposeStreamProviderRef<List<BloodRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserActiveRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<BloodRequest>>
    with UserActiveRequestsRef {
  _UserActiveRequestsProviderElement(super.provider);

  @override
  String get userId => (origin as UserActiveRequestsProvider).userId;
}

String _$userFulfilledRequestsHash() =>
    r'00d0339446508cf716ced48437677b54d9ffc545';

/// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
///
/// Copied from [userFulfilledRequests].
@ProviderFor(userFulfilledRequests)
const userFulfilledRequestsProvider = UserFulfilledRequestsFamily();

/// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
///
/// Copied from [userFulfilledRequests].
class UserFulfilledRequestsFamily
    extends Family<AsyncValue<List<BloodRequest>>> {
  /// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
  ///
  /// Copied from [userFulfilledRequests].
  const UserFulfilledRequestsFamily();

  /// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
  ///
  /// Copied from [userFulfilledRequests].
  UserFulfilledRequestsProvider call(
    String userId,
  ) {
    return UserFulfilledRequestsProvider(
      userId,
    );
  }

  @override
  UserFulfilledRequestsProvider getProviderOverride(
    covariant UserFulfilledRequestsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userFulfilledRequestsProvider';
}

/// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
///
/// Copied from [userFulfilledRequests].
class UserFulfilledRequestsProvider
    extends AutoDisposeStreamProvider<List<BloodRequest>> {
  /// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
  ///
  /// Copied from [userFulfilledRequests].
  UserFulfilledRequestsProvider(
    String userId,
  ) : this._internal(
          (ref) => userFulfilledRequests(
            ref as UserFulfilledRequestsRef,
            userId,
          ),
          from: userFulfilledRequestsProvider,
          name: r'userFulfilledRequestsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userFulfilledRequestsHash,
          dependencies: UserFulfilledRequestsFamily._dependencies,
          allTransitiveDependencies:
              UserFulfilledRequestsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserFulfilledRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<BloodRequest>> Function(UserFulfilledRequestsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserFulfilledRequestsProvider._internal(
        (ref) => create(ref as UserFulfilledRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BloodRequest>> createElement() {
    return _UserFulfilledRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserFulfilledRequestsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserFulfilledRequestsRef
    on AutoDisposeStreamProviderRef<List<BloodRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserFulfilledRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<BloodRequest>>
    with UserFulfilledRequestsRef {
  _UserFulfilledRequestsProviderElement(super.provider);

  @override
  String get userId => (origin as UserFulfilledRequestsProvider).userId;
}

String _$userCanceledRequestsHash() =>
    r'791f207aa05d52a6c4d0eb3ac37c7700ed807d89';

/// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
///
/// Copied from [userCanceledRequests].
@ProviderFor(userCanceledRequests)
const userCanceledRequestsProvider = UserCanceledRequestsFamily();

/// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
///
/// Copied from [userCanceledRequests].
class UserCanceledRequestsFamily
    extends Family<AsyncValue<List<BloodRequest>>> {
  /// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
  ///
  /// Copied from [userCanceledRequests].
  const UserCanceledRequestsFamily();

  /// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
  ///
  /// Copied from [userCanceledRequests].
  UserCanceledRequestsProvider call(
    String userId,
  ) {
    return UserCanceledRequestsProvider(
      userId,
    );
  }

  @override
  UserCanceledRequestsProvider getProviderOverride(
    covariant UserCanceledRequestsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userCanceledRequestsProvider';
}

/// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
///
/// Copied from [userCanceledRequests].
class UserCanceledRequestsProvider
    extends AutoDisposeStreamProvider<List<BloodRequest>> {
  /// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
  ///
  /// Copied from [userCanceledRequests].
  UserCanceledRequestsProvider(
    String userId,
  ) : this._internal(
          (ref) => userCanceledRequests(
            ref as UserCanceledRequestsRef,
            userId,
          ),
          from: userCanceledRequestsProvider,
          name: r'userCanceledRequestsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userCanceledRequestsHash,
          dependencies: UserCanceledRequestsFamily._dependencies,
          allTransitiveDependencies:
              UserCanceledRequestsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserCanceledRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<BloodRequest>> Function(UserCanceledRequestsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserCanceledRequestsProvider._internal(
        (ref) => create(ref as UserCanceledRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BloodRequest>> createElement() {
    return _UserCanceledRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCanceledRequestsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserCanceledRequestsRef
    on AutoDisposeStreamProviderRef<List<BloodRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserCanceledRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<BloodRequest>>
    with UserCanceledRequestsRef {
  _UserCanceledRequestsProviderElement(super.provider);

  @override
  String get userId => (origin as UserCanceledRequestsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
