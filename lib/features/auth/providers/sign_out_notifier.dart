import 'package:kan_bul/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/utils/logger.dart';

part 'sign_out_notifier.g.dart';

@riverpod
class SignOutNotifier extends _$SignOutNotifier {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> run() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logger.e("SignOutNotifier: Sign out error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
