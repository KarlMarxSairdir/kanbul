// lib/core/services/location_service.dart
import 'dart:io'; // Import Platform

import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:logger/logger.dart'; // Import the logger package
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Riverpod kod üretimi için
import 'package:riverpod/riverpod.dart';
part 'location_service.g.dart'; // Kod üretimi için part direktifi

/// Konum hata tiplerini temsil eden enum
enum LocationFailureType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// Konum izinleri ve hata durumlarını temsil eden sınıf
class LocationResult {
  final bool isSuccess;
  final LocationPermission? permission;
  final LocationFailureType? failureType;
  final String? errorMessage;

  LocationResult.success(this.permission)
    : isSuccess = true,
      failureType = null,
      errorMessage = null;

  LocationResult.failure(this.failureType, this.errorMessage)
    : isSuccess = false,
      permission = null;

  bool get hasPermission =>
      isSuccess &&
      (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always);
}

/// Konum işlemlerini yöneten servis
class LocationService {
  final Logger _logger = logger;

  LocationService();

  Future<LocationResult> checkAndRequestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w("LocationService: Konum servisleri kapalı");
        return LocationResult.failure(
          LocationFailureType.serviceDisabled,
          'Konum servisleri kapalı. Lütfen cihazınızın konum servislerini açın.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w("LocationService: Konum izni reddedildi");
          return LocationResult.failure(
            LocationFailureType.permissionDenied,
            'Konum izni reddedildi. Yakınlardaki kan taleplerini görmek için konum izni gereklidir.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w(
          'Konum izinleri kalıcı olarak reddedildi, izin isteyemiyoruz.',
        );
        return LocationResult.failure(
          LocationFailureType.permissionDeniedForever,
          'Konum izinleri kalıcı olarak reddedildi. Lütfen ayarlardan manuel olarak izin verin.',
        );
      }

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Konum servisleri devre dışı.');
        return LocationResult.failure(
          LocationFailureType.serviceDisabled,
          'Konum servisleri açık değil. Lütfen konum servislerini açın.',
        );
      }

      _logger.d(
        "LocationService: Konum izinleri başarıyla alındı: $permission",
      );
      return LocationResult.success(permission);
    } catch (e, s) {
      _logger.e(
        "LocationService: Konum izni kontrolünde hata",
        error: e,
        stackTrace: s,
      );
      return LocationResult.failure(
        null,
        'Konum izinleri kontrol edilirken beklenmedik bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      _logger.i(
        "LocationService: Konum alındı: ${position.latitude}, ${position.longitude}",
      );
      return position;
    } catch (e, s) {
      _logger.e("LocationService: Konum alınamadı", error: e, stackTrace: s);
      return null;
    }
  }

  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    _logger.d("Starting location stream...");
    final LocationSettings settings =
        locationSettings ?? _determineLocationSettings();

    return Geolocator.getPositionStream(locationSettings: settings);
  }

  LocationSettings _determineLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Konum Güncellemeleri',
          notificationText: 'Konum güncellemeleri arka planda devam ediyor',
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }
}

/// LocationService provider'ı
@riverpod
LocationService locationService(Ref ref) {
  // Ref tipi düzeltildi
  return LocationService();
}
