import 'package:kan_bul/core/services/location_service.dart';
import 'package:kan_bul/features/blood_request/presentation/providers/top_nearby_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_nearby_refresh_notifier.g.dart';

/// En yakın kan taleplerini yenileyen notifier.
/// Özel yenileme butonu veya pull-to-refresh gibi kullanıcı etkileşimleri için kullanılır.
@Riverpod(keepAlive: true)
class TopNearbyRefreshNotifier extends _$TopNearbyRefreshNotifier {
  @override
  FutureOr<void> build() {
    // İlk yükleme sırasında bir şey yapma
    return null;
  }

  /// En yakın kan taleplerini yeniler.
  /// Güncel konum bilgisini alır ve TopNearbyNotifier'ı çalıştırır.
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      // Güncel konum bilgisini al
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();

      // Konum null ise işlemi durdur
      if (position == null) {
        state = const AsyncValue.error(
          "Konum bilgisi alınamadı",
          StackTrace.empty,
        );
        return;
      }

      // Aktif kullanıcı ID'sini al
      // final user = ref.read(authStateNotifierProvider).user; // This line was removed as 'user' was not used.
      // If TopNearbyNotifier now gets userId via ref.watch,
      // this local variable might not be directly used by the lines below.

      // TopNearbyNotifier'ı geçersiz kıl ve yeniden oluşturulmasını bekle
      ref.invalidate(topNearbyNotifierProvider);
      // Await the future of the invalidated provider to ensure the refresh completes
      // and to propagate any errors from TopNearbyNotifier's build method.
      await ref.read(topNearbyNotifierProvider.future);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
