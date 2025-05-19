import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';

part 'email_verification_notifier.g.dart';

@riverpod
class EmailVerificationNotifier extends _$EmailVerificationNotifier {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      // Refresh the user data to update the emailVerified status
      await ref.read(authStateNotifierProvider.notifier).refreshUser();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.e(
        "EmailVerificationNotifier: Error sending verification",
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).reloadCurrentUser();
      await ref.read(authStateNotifierProvider.notifier).refreshUser();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.e(
        "EmailVerificationNotifier: Error checking verification",
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
