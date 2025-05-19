import 'package:riverpod/riverpod.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;

enum AuthActionType { none, signOut, emailVerification, locationUpdated }

/// Auth ile ilgili temel aksiyonları (çıkış yapma, email doğrulama, vs) içeren bir sınıf.
final authActionNotifierProvider =
    StateNotifierProvider<AuthActionNotifier, AsyncValue<AuthActionType>>((
      ref,
    ) {
      return AuthActionNotifier(ref);
    });

class AuthActionNotifier extends StateNotifier<AsyncValue<AuthActionType>> {
  final Ref _ref;

  AuthActionNotifier(this._ref)
    : super(const AsyncValue.data(AuthActionType.none));

  /// Kullanıcının oturumunu kapatır
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    logger.d("AuthActionNotifier: signOut running");

    try {
      await _ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(AuthActionType.signOut);
      logger.d("AuthActionNotifier: User signed out successfully");
    } catch (e, stack) {
      logger.e(
        "AuthActionNotifier: Sign out error",
        error: e,
        stackTrace: stack,
      );
      state = AsyncValue.error(e, stack);
    }
  }

  /// E-posta doğrulama e-postası gönderir
  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    logger.d("AuthActionNotifier: sendEmailVerification running");

    try {
      await _ref.read(authRepositoryProvider).sendEmailVerification();
      state = const AsyncValue.data(AuthActionType.emailVerification);
      logger.d("AuthActionNotifier: Email verification sent successfully");
    } catch (e, stack) {
      logger.e(
        "AuthActionNotifier: Email verification error",
        error: e,
        stackTrace: stack,
      );
      state = AsyncValue.error(e, stack);
    }
  }

  /// Kullanıcının konum bilgisini günceller
  Future<void> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    state = const AsyncValue.loading();
    logger.d("AuthActionNotifier: updateUserLocation running for user $userId");

    try {
      // Firestore GeoPoint oluştur
      final geoPoint = GeoPoint(latitude, longitude);

      // Repository'e ilet
      await _ref
          .read(authRepositoryProvider)
          .updateUserLocation(userId, geoPoint);

      state = const AsyncValue.data(AuthActionType.locationUpdated);
      logger.d("AuthActionNotifier: User location updated successfully");
    } catch (e, stack) {
      logger.e(
        "AuthActionNotifier: Update location error",
        error: e,
        stackTrace: stack,
      );
      state = AsyncValue.error(e, stack);
    }
  }

  /// State'i sıfırlar
  void reset() {
    state = const AsyncValue.data(AuthActionType.none);
  }
}
