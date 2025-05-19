// lib/features/dashboard/presentation/widgets/nearby_requests_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/location_provider.dart'; // currentPositionProvider için
import 'package:kan_bul/features/blood_request/presentation/providers/top_nearby_notifier.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/dashboard_list_helpers.dart'; // Helper widget'larınız
import 'package:kan_bul/core/utils/logger.dart';

class NearbyRequestsListWidget extends ConsumerWidget {
  // ConsumerStatefulWidget'tan ConsumerWidget'a dönüştü
  const NearbyRequestsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TopNearbyNotifier, kendi içinde konum ve auth state'i dinlediği için,
    // burada ayrıca konum veya auth state'i kontrol edip run() çağırmamıza gerek yok.
    // Sadece TopNearbyNotifier'ın sonucunu dinleyeceğiz.
    final nearbyRequestsAsync = ref.watch(topNearbyNotifierProvider);

    // UI'da konum hatası veya yükleniyor durumu göstermek için currentPositionProvider'ı da izleyebiliriz.
    final positionAsync = ref.watch(currentPositionProvider);

    // 1. Genel Konum Yükleme/Hata Durumu
    if (positionAsync.isLoading) {
      logger.d("NearbyRequestsListWidget: Konum yükleniyor (UI için)...");
      return buildLoadingList(); // Genel bir yükleme göstergesi
    }

    if (positionAsync.hasError) {
      logger.w(
        "NearbyRequestsListWidget: Konum alınırken hata (UI için). Error: ${positionAsync.error}",
      );
      return buildErrorWidget(
        context,
        ref,
        'Konum bilgisi alınamadı. Lütfen konum servislerinizi kontrol edin.',
        () => ref.invalidate(
          currentPositionProvider,
        ), // Sadece konumu yenilemeyi dene
      );
    }

    if (positionAsync.value == null && !positionAsync.hasValue) {
      // Bu durum, provider'ın henüz bir değer döndürmediği anlamına gelir.
      // Genellikle isLoading ile yakalanır, ancak ek bir kontrol olabilir.
      logger.w(
        "NearbyRequestsListWidget: Konum değeri null ve hasValue false (UI için).",
      );
      return buildNoLocationCard(context); // Veya buildLoadingList()
    }

    // 2. Konum var, şimdi yakındaki talepleri işle
    return nearbyRequestsAsync.when(
      data: (requests) {
        logger.i(
          "NearbyRequestsListWidget: Talepler yüklendi (nearbyRequestsAsync): ${requests.length} adet.",
        );
        if (requests.isEmpty) {
          logger.i(
            "NearbyRequestsListWidget: Yakında talep yok, boş liste gösteriliyor.",
          );
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: buildEmptyListWidget(
                    context,
                    'Çevrenizde size uygun aktif kan talebi bulunmuyor.',
                    isUserList: false,
                  ),
                ),
              ],
            ),
          );
        }
        logger.i(
          "NearbyRequestsListWidget: Talepler gösteriliyor: ${requests.length} adet.",
        );
        // positionAsync.value! burada güvenle kullanılabilir çünkü yukarıda kontrol edildi.
        return buildListView(context, requests, positionAsync.value!, false);
      },
      loading: () {
        logger.d(
          "NearbyRequestsListWidget: Talepler yükleniyor (nearbyRequestsAsync)...",
        );
        return buildLoadingList();
      },
      error: (e, s) {
        logger.e(
          "NearbyRequestsListWidget: Talep yükleme hatası (nearbyRequestsAsync).",
          error: e,
          stackTrace: s,
        );
        return buildErrorWidget(
          context,
          ref,
          'Yakındaki talepler yüklenirken bir sorun oluştu.',
          () {
            // Hem talepleri hem de belki konumu tekrar invalidate et.
            ref.invalidate(topNearbyNotifierProvider);
            // ref.invalidate(currentPositionProvider); // Gerekirse konumu da yenile
          },
        );
      },
    );
  }
}
