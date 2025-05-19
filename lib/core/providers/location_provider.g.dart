// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentPositionHash() => r'cb74c072c50d79c5133c8cc4f0b1464f5b4dddec';

/// Mevcut kullanıcı konumunu tek seferlik almak için provider
///
/// Copied from [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeFutureProvider<Position?>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeFutureProviderRef<Position?>;
String _$locationStreamHash() => r'89455dad743656dde100519dc2bcaac53497ae47';

/// Konum değişikliklerini sürekli dinleyen stream provider
///
/// Copied from [locationStream].
@ProviderFor(locationStream)
final locationStreamProvider = AutoDisposeStreamProvider<Position>.internal(
  locationStream,
  name: r'locationStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationStreamRef = AutoDisposeStreamProviderRef<Position>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
