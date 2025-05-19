import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/core/providers/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/services/notification_service.dart'; // Yeni provider için import

part 'auth_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  StreamSubscription<firebase_auth.User?>? _sub;

  @override
  AuthState build() {
    // Başlangıç state'i
    state = const AuthState(isLoading: true);
    // Sadece bir kez abone ol
    _sub = ref
        .read(authRepositoryProvider)
        .authStateChanges
        .listen(_onAuthChanged);
    ref.onDispose(() => _sub?.cancel());
    // Mevcut kullanıcıyı kontrol et
    _onAuthChanged(ref.read(authRepositoryProvider).currentAuthUser);
    return state;
  }

  Future<void> _onAuthChanged(firebase_auth.User? u) async {
    if (u == null) {
      state = const AuthState(isLoading: false, user: null);
    } else {
      state = state.copyWith(isLoading: true);
      try {
        final userModel =
            await ref.read(authRepositoryProvider).ensureCurrentUserLoaded();
        state = AuthState(isLoading: false, user: userModel);

        // KULLANICI MODELİ YÜKLENDİKTEN SONRA TOKEN KAYDETME
        if (userModel != null) {
          logger.d(
            "AuthStateNotifier: UserModel yüklendi (\${userModel.id}), FCM token kaydı tetikleniyor.",
          );
          try {
            // notificationService provider'ını (üretilmiş olan) okuyarak token kaydet
            final notificationServ = ref.read(
              notificationServiceProvider,
            ); // build_runner sonrası oluşacak ismi kullanın
            await notificationServ.saveTokenToFirestore();
          } catch (e, s) {
            logger.e(
              "AuthStateNotifier: _onAuthChanged içinde token kaydetme hatası",
              error: e,
              stackTrace: s,
            );
          }
        }
      } catch (e, s) {
        logger.e(
          "AuthStateNotifier: _onAuthChanged - ensureCurrentUserLoaded hatası",
          error: e,
          stackTrace: s,
        );
        state = const AuthState(isLoading: false, user: null);
      }
    }
  }

  /// Kullanıcıyı sunucudan yeniden yükler ve state'i günceller
  Future<void> refreshUser() async {
    logger.d("AuthStateNotifier: refreshUser çağrıldı");
    final authRepo = ref.read(authRepositoryProvider);

    if (authRepo.currentAuthUser == null) {
      logger.d("AuthStateNotifier: refreshUser - Kullanıcı oturum açmamış");
      state = const AuthState(isLoading: false, user: null);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await authRepo.reloadCurrentUser();
      final updatedUserModel = await authRepo.ensureCurrentUserLoaded();
      state = AuthState(isLoading: false, user: updatedUserModel);
      logger.d("AuthStateNotifier: User refreshed successfully");
    } catch (e, s) {
      logger.e("AuthStateNotifier: refreshUser error", error: e, stackTrace: s);
      state = const AuthState(isLoading: false, user: null);
      rethrow;
    }
  }
}
