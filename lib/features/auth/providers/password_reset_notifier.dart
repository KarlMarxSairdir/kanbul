// import 'package:riverpod/riverpod.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_reset_notifier.g.dart';

/// Şifre sıfırlama işlemi için özel notifier sınıfı.
/// AsyncNotifier kullanarak loading/error/data durumlarını yönetir.
// final passwordResetNotifierProvider =
//     StateNotifierProvider<PasswordResetNotifier, AsyncValue<void>>((ref) {
//       return PasswordResetNotifier(ref);
//     });

@riverpod
class PasswordResetNotifier extends _$PasswordResetNotifier {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> run(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.e("PasswordResetNotifier: Reset error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
