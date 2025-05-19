// lib/core/providers/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/services/location_service.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // GeoPoint için gerekli
import 'package:rxdart/rxdart.dart';
import 'package:kan_bul/core/providers/permission_provider.dart'; // permissionCheckProvider için eklendi

part 'location_provider.g.dart';

/// Mevcut kullanıcı konumunu tek seferlik almak için provider
@riverpod
Future<Position?> currentPosition(Ref ref) async {
  final locationService = ref.watch(locationServiceProvider);
  logger.d("currentPositionProvider: Mevcut konum alınıyor");

  final hasPermission = await ref.watch(permissionCheckProvider.future);
  if (!hasPermission) {
    logger.w("currentPositionProvider: Konum izni yok (permission_provider).");
    return null;
  }

  try {
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      logger.i(
        "currentPositionProvider: Konum alındı: ${position.latitude}, ${position.longitude}",
      );
      _updateUserLocationInFirestore(ref, position);
      return position;
    } else {
      logger.w("currentPositionProvider: Konum alınamadı (null)");
      return null;
    }
  } catch (e, s) {
    logger.e(
      "currentPositionProvider: Konum alınırken hata",
      error: e,
      stackTrace: s,
    );
    return null;
  }
}

/// Konum değişikliklerini sürekli dinleyen stream provider
@riverpod
Stream<Position> locationStream(Ref ref) {
  final locationService = ref.watch(locationServiceProvider);
  logger.d("locationStreamProvider: Konum stream'i başlatılıyor");

  return ref.watch(permissionCheckProvider.future).asStream().asyncExpand((
    hasPermission,
  ) {
    if (!hasPermission) {
      logger.w(
        "locationStreamProvider: Konum izni yok (permission_provider). Stream veri yaymayacak.",
      );
      return Stream.empty(); // İzin yoksa boş stream döndür
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    return locationService
        .getPositionStream(locationSettings: locationSettings)
        .debounceTime(const Duration(seconds: 5))
        .map((position) {
          // getPositionStream non-null Position döndürdüğü için null kontrolü kaldırıldı.
          logger.d(
            "locationStreamProvider: Yeni konum alındı: ${position.latitude}, ${position.longitude}",
          );
          _updateUserLocationInFirestore(ref, position);
          return position;
        });
    // .where ve .cast kaldırıldı çünkü map zaten Position döndürüyor ve getPositionStream null döndürmüyor.
  });
}

/// Kullanıcı konumunu Firestore'da güncelleyen helper fonksiyon
void _updateUserLocationInFirestore(Ref ref, Position position) {
  final user = ref.read(authStateNotifierProvider).user;

  if (user == null) {
    logger.w(
      "locationProvider: _updateUserLocationInFirestore - Kullanıcı oturum açmamış",
    );
    return;
  }
  final authRepo = ref.read(authRepositoryProvider);
  final geoPoint = GeoPoint(position.latitude, position.longitude);

  authRepo
      .updateUserLocation(user.id, geoPoint)
      .then((_) {
        logger.d("locationProvider: Kullanıcı konumu güncellendi: ${user.id}");
      })
      .catchError((e, s) {
        logger.e(
          "locationProvider: Konum güncellenirken hata",
          error: e,
          stackTrace: s,
        );
      });
}
