import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/features/auth/providers/auth_action_notifier.dart';
import 'package:kan_bul/core/providers/permission_provider.dart';
import 'package:kan_bul/core/services/firestore_service.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/core/providers/shared_preferences_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

// State class for the screen
class PermissionRequestScreenData {
  final bool isLoading;
  final LocationPermissionStatus locationStatus;
  final String? errorMessage;
  final bool shouldShowSettingsDialog;
  final bool shouldNavigateToDashboard;
  final UserRole? userRoleForNavigation;

  PermissionRequestScreenData({
    this.isLoading = true,
    this.locationStatus = LocationPermissionStatus.unknown,
    this.errorMessage,
    this.shouldShowSettingsDialog = false,
    this.shouldNavigateToDashboard = false,
    this.userRoleForNavigation,
  });

  PermissionRequestScreenData copyWith({
    bool? isLoading,
    LocationPermissionStatus? locationStatus,
    String? errorMessage,
    bool? clearErrorMessage, // To explicitly clear the error message
    bool? shouldShowSettingsDialog,
    bool? shouldNavigateToDashboard,
    UserRole? userRoleForNavigation,
    bool? clearNavigation, // To explicitly clear navigation flags
  }) {
    return PermissionRequestScreenData(
      isLoading: isLoading ?? this.isLoading,
      locationStatus: locationStatus ?? this.locationStatus,
      errorMessage:
          clearErrorMessage == true ? null : errorMessage ?? this.errorMessage,
      shouldShowSettingsDialog:
          shouldShowSettingsDialog ?? this.shouldShowSettingsDialog,
      shouldNavigateToDashboard:
          clearNavigation == true
              ? false
              : (shouldNavigateToDashboard ?? this.shouldNavigateToDashboard),
      userRoleForNavigation:
          clearNavigation == true
              ? null
              : (userRoleForNavigation ?? this.userRoleForNavigation),
    );
  }
}

final permissionRequestScreenControllerProvider =
    StateNotifierProvider.autoDispose<
      PermissionRequestScreenController,
      PermissionRequestScreenData
    >((ref) {
      return PermissionRequestScreenController(ref);
    });

class PermissionRequestScreenController
    extends StateNotifier<PermissionRequestScreenData> {
  final Ref _ref;
  late final FirestoreService _firestoreService;
  late final Logger _logger;

  PermissionRequestScreenController(this._ref)
    : super(PermissionRequestScreenData()) {
    _firestoreService = _ref.read(firestoreServiceProvider);
    _logger = logger;
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    _logger.d(
      "PermissionRequestScreenController: Checking initial permissions...",
    );
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final initialLocationStatus = await _ref.read(
        locationPermissionStatusProvider.future,
      );
      state = state.copyWith(locationStatus: initialLocationStatus);
      _logger.d(
        "PermissionRequestScreenController: Initial location status: $initialLocationStatus",
      );

      if (initialLocationStatus == LocationPermissionStatus.granted ||
          initialLocationStatus == LocationPermissionStatus.limited) {
        // SharedPreferences'a doğru şekilde erişim sağla
        final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
        final userPreviouslyAccepted =
            prefsAsync.getBool('permissionsRequested') ?? false;

        if (userPreviouslyAccepted) {
          // Durumu güncelleyip, asıl kontrolü permissionCheckProvider'a bırakıyoruz.
          await _ref
              .read(permissionStatusProvider.notifier)
              .updatePermissionStatus(true);
          final permissionGranted = await _ref.read(
            permissionCheckProvider.future,
          );

          if (permissionGranted) {
            final authState = _ref.read(authStateNotifierProvider);
            state = state.copyWith(
              isLoading: false,
              shouldNavigateToDashboard: true,
              userRoleForNavigation: authState.user?.role,
            );
            return;
          }
        } else {
          // Sistem izni var ama kullanıcı uygulama içinde kabul etmemiş, ekranda kalmalı
          state = state.copyWith(isLoading: false);
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (e, s) {
      _logger.e(
        "PermissionRequestScreenController: Error checking initial permissions",
        error: e,
        stackTrace: s,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: "İzin kontrolü sırasında hata: $e",
      );
    }
  }

  Future<void> requestPermission() async {
    _logger.d(
      "PermissionRequestScreenController: Requesting location permission...",
    );
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      shouldShowSettingsDialog: false,
    );

    try {
      final status = await _ref.read(requestLocationPermissionProvider.future);
      state = state.copyWith(locationStatus: status);
      _logger.d(
        "PermissionRequestScreenController: Permission request result: $status",
      );

      final authState = _ref.read(authStateNotifierProvider);
      if (authState.user != null) {
        await _firestoreService.updateUserData(authState.user!.id, {
          'settings.locationPermissionAsked': true,
          'settings.locationSharingEnabled':
              (status == LocationPermissionStatus.granted ||
                  status == LocationPermissionStatus.limited),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (status == LocationPermissionStatus.granted ||
          status == LocationPermissionStatus.limited) {
        // permissionStatusProvider aracılığıyla durumu güncelle, bu da permissionCheckProvider'ı tetikleyecektir.
        await _ref
            .read(permissionStatusProvider.notifier)
            .updatePermissionStatus(true);
        _logger.i(
          "PermissionRequestScreenController: SharedPreferences güncellendi ve provider'lar invalidate edildi.",
        );

        // permissionCheckProvider'ı yenileyerek en son durumu al
        final bool finalPermissionGranted = await _ref.refresh(
          permissionCheckProvider.future,
        );
        _logger.i(
          "PermissionRequestScreenController: permissionCheckProvider sonucu: $finalPermissionGranted",
        );

        if (finalPermissionGranted) {
          state = state.copyWith(
            isLoading: false,
            shouldNavigateToDashboard: true,
            userRoleForNavigation:
                authState.user?.role, // authState zaten yukarıda okundu
          );
        } else {
          _logger.w(
            "PermissionRequestScreenController: Permission granted by system but permissionCheckProvider is false (likely userAccepted in prefs was false initially and now true, but provider needs re-evaluation or direct update)",
          );
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                "İzin verildi ancak bir senkronizasyon sorunu oluştu. Tekrar deneyin.",
          );
        }
      } else if (status == LocationPermissionStatus.permanentlyDenied ||
          status == LocationPermissionStatus.restricted) {
        // Kullanıcı izinleri kalıcı olarak reddettiğinde veya kısıtlandığında
        // SharedPreferences'taki 'permissionsRequested' bayrağını false yap
        final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
        await prefsAsync.setBool('permissionsRequested', false);
        // permissionStatusProvider aracılığıyla durumu güncelle
        await _ref
            .read(permissionStatusProvider.notifier)
            .updatePermissionStatus(false);

        state = state.copyWith(
          isLoading: false,
          shouldShowSettingsDialog: true,
        );
      } else {
        // Denied
        // SharedPreferences'a doğru şekilde erişim sağla
        final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
        await prefsAsync.setBool('permissionsRequested', false);

        await _ref
            .read(permissionStatusProvider.notifier)
            .updatePermissionStatus(false);
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Konum iznine ihtiyacımız var. Lütfen izin verin.",
        );
      }
    } catch (e, s) {
      _logger.e(
        "PermissionRequestScreenController: Error requesting permission",
        error: e,
        stackTrace: s,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: "İzin istenirken hata: $e",
      );
    }
  }

  Future<void> declinePermissionsTemporarily() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      // SharedPreferences'a doğru şekilde erişim sağla
      final prefsAsync = await _ref.read(sharedPreferencesProvider.future);
      await prefsAsync.setBool('permissionsRequested', false);

      _ref
          .read(permissionStatusProvider.notifier)
          .updatePermissionStatus(false);

      await _ref.read(authActionNotifierProvider.notifier).signOut();
      // Navigation will be handled by the router listening to auth state changes.
    } catch (e, s) {
      _logger.e(
        "Error in declinePermissionsTemporarily",
        error: e,
        stackTrace: s,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Bir hata oluştu.",
      );
    }
    // Ensure isLoading is set to false in all paths
    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
  }

  void consumeSideEffects() {
    state = state.copyWith(
      clearErrorMessage: true,
      shouldShowSettingsDialog: false,
      clearNavigation: true,
    );
  }

  void navigationHandled() {
    state = state.copyWith(clearNavigation: true);
  }

  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    _logger.d(
      "PermissionRequestScreenController: updateUserLocation çağrıldı for $userId",
    );
    try {
      await _firestoreService.updateUserData(userId, {
        'profileData.location': location,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.d(
        "PermissionRequestScreenController: Kullanıcı konumu güncellendi: $userId",
      );
    } catch (e, s) {
      _logger.e(
        "PermissionRequestScreenController - Konum Güncelleme Hatası",
        error: e,
        stackTrace: s,
      );
      throw Exception("Konum güncellenirken bir hata oluştu: $e");
    }
  }
}
