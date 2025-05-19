// lib/core/providers/permission_provider.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kan_bul/core/providers/shared_preferences_provider.dart';

part 'permission_provider.g.dart';

/// İzin durumunu kontrol eden provider - Hem kullanıcının "kullanım kabul ettiği" hem de gerçek konum iznini kontrol eder
@riverpod
Future<bool> permissionCheck(Ref ref) async {
  logger.d("permissionCheckProvider: İzin kontrolü başlatıldı");

  ref.keepAlive();
  try {
    // Prefs'den kullanıcının kabul ettiği durumu kontrol edelim
    final SharedPreferences prefs = await ref.watch(
      sharedPreferencesProvider.future,
    );
    final userAccepted = prefs.getBool('permissionsRequested') ?? false;

    if (!userAccepted) {
      logger.d(
        "permissionCheckProvider: Kullanıcı henüz izinleri kabul etmemiş",
      );
      return false;
    }

    // Sistem izinlerini kontrol et - konum izni gerekli
    final locationPermission = await Permission.locationWhenInUse.status;
    final hasLocationPermission =
        locationPermission.isGranted || locationPermission.isLimited;

    logger.d(
      "permissionCheckProvider: 'permissionsRequested': $userAccepted, Gerçek konum izni: $hasLocationPermission",
    );

    // Kullanıcı sayfada kabul etmiş VE gerçekten de sistem izni var mı?
    return userAccepted && hasLocationPermission;
  } catch (e, s) {
    logger.e(
      "permissionCheckProvider: İzin kontrolü hatası",
      error: e,
      stackTrace: s,
    );
    return false;
  }
}

/// Gerçek konum izni durumunu kontrol eden provider
@riverpod
Future<LocationPermissionStatus> locationPermissionStatus(Ref ref) async {
  logger.d(
    "locationPermissionStatusProvider: Konum izni durumu kontrol ediliyor",
  );

  try {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    } else if (status.isDenied) {
      return LocationPermissionStatus.denied;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    } else if (status.isLimited) {
      return LocationPermissionStatus.limited;
    } else if (status.isRestricted) {
      return LocationPermissionStatus.restricted;
    } else {
      return LocationPermissionStatus.unknown;
    }
  } catch (e, s) {
    logger.e("locationPermissionStatusProvider: Hata", error: e, stackTrace: s);
    return LocationPermissionStatus.error;
  }
}

/// Konum izni durumunu kontrol etmek için enum
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  unknown,
  error,
}

/// İzin talep fonksiyonu - direkt permission_handler'ı kullanır
@riverpod
Future<LocationPermissionStatus> requestLocationPermission(Ref ref) async {
  logger.d("requestLocationPermissionProvider: Konum izni talep ediliyor");

  try {
    final status = await Permission.locationWhenInUse.request();

    // İzin durumu sonrası tüm provider'ları yenile
    ref.invalidate(locationPermissionStatusProvider);
    ref.invalidate(permissionCheckProvider);

    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    } else if (status.isDenied) {
      return LocationPermissionStatus.denied;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    } else if (status.isLimited) {
      return LocationPermissionStatus.limited;
    } else if (status.isRestricted) {
      return LocationPermissionStatus.restricted;
    } else {
      return LocationPermissionStatus.unknown;
    }
  } catch (e, s) {
    logger.e(
      "requestLocationPermissionProvider: Hata",
      error: e,
      stackTrace: s,
    );
    return LocationPermissionStatus.error;
  }
}

/// İzin durumunu güncelleyen method provider
@riverpod
class PermissionStatus extends _$PermissionStatus {
  @override
  bool build() {
    // Başlangıç değerini SharedPreferences'tan oku
    final asyncPrefs = ref.watch(sharedPreferencesProvider);

    return asyncPrefs.maybeWhen(
      data: (prefs) => prefs.getBool('permissionsRequested') ?? false,
      orElse: () {
        logger.w(
          "PermissionStatus build: SharedPreferences yüklenemedi veya henüz hazır değil, varsayılan 'false' kullanılıyor.",
        );
        return false;
      },
    );
  }

  /// İzin durumunu güncelle ve kaydet
  Future<void> updatePermissionStatus(bool granted) async {
    if (granted == state) {
      return; // Değişiklik yoksa işlem yapma
    }

    logger.d("PermissionStatusProvider: İzin durumu güncelleniyor: $granted");
    try {
      final SharedPreferences prefs = await ref.read(
        sharedPreferencesProvider.future,
      );
      await prefs.setBool('permissionsRequested', granted);
      state = granted; // State'i güncelle

      // permissionCheckProvider'ı yenile - kullanıcı tercihi değiştiği için
      ref.invalidate(permissionCheckProvider);

      logger.d("PermissionStatusProvider: İzin durumu başarıyla güncellendi");
    } catch (e, s) {
      logger.e(
        "PermissionStatusProvider: İzin durumu güncellenirken hata",
        error: e,
        stackTrace: s,
      );
      // Hata durumunda state'i değiştirmeyin
    }
  }
}
