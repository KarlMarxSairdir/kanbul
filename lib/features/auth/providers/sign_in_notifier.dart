// import 'package:riverpod/riverpod.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_notifier.g.dart';

/// Giriş işlemi için özel notifier sınıfı.
/// AsyncNotifier kullanarak loading/error/data durumlarını yönetir.
// final signInNotifierProvider =
//     StateNotifierProvider<SignInNotifier, AsyncValue<UserModel?>>((ref) {
//       return SignInNotifier(ref);
//     });

@riverpod
class SignInNotifier extends _$SignInNotifier {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<UserModel> run({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email, password: password);
      state = AsyncValue.data(null);
      return user;
    } catch (e, st) {
      logger.e("SignInNotifier: Login error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      state = AsyncValue.data(null);
      return user;
    } catch (e, st) {
      logger.e("SignInNotifier: Google login error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// State'i sıfırlar - form reset veya sayfa değişiminde kullanılabilir
  void reset() {
    state = const AsyncValue.data(null);
  }
}
