// lib/features/blood_request/presentation/providers/top_nearby_notifier.dart
import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Unnecessary import
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/core/providers/location_provider.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart';
import 'package:kan_bul/features/blood_request/domain/blood_request_service.dart';
import 'package:kan_bul/features/blood_request/domain/models/request_with_distance.dart';
import 'package:kan_bul/core/utils/blood_compatibility.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_nearby_notifier.g.dart';

@riverpod
class TopNearbyNotifier extends _$TopNearbyNotifier {
  @override
  FutureOr<List<RequestWithDistance>> build() async {
    logger.i("TopNearbyNotifier: build() metodu BAŞLADI.");

    // Bağımlılıkları dinle
    final authState = ref.watch(authStateNotifierProvider);
    final positionAsync = ref.watch(currentPositionProvider);

    final userId = authState.user?.id;
    final userBloodType = authState.user?.profileData.bloodType;
    final Position? currentPosition = positionAsync.value;

    logger.d(
      "TopNearbyNotifier build(): UserID: $userId, UserBloodType: $userBloodType, Position: ${currentPosition?.latitude},${currentPosition?.longitude}",
    );

    // Gerekli veriler (kullanıcı ve konum) henüz hazır değilse, boş liste döndür ve yükleniyor gösterme.
    // Notifier'ın kendisi FutureProvider olduğu için Riverpod yüklenme durumunu yönetecektir.
    if (userId == null || currentPosition == null) {
      logger.w(
        "TopNearbyNotifier build(): Kullanıcı (${userId == null ? 'YOK' : 'VAR'}) veya konum (${currentPosition == null ? 'YOK' : 'VAR'}) henüz hazır değil. Boş liste dönülüyor.",
      );
      return [];
    }

    // Artık veriler hazır, işlemleri yapabiliriz.
    logger.i(
      "TopNearbyNotifier build(): Konum ve kullanıcı hazır. Talepler işleniyor...",
    );

    try {
      final bloodRequestRepository = ref.read(bloodRequestRepositoryProvider);
      // Tek seferlik tüm aktif talepleri çek (limitli veya limitsiz, projenin ölçeğine göre karar verilmeli)
      // Şimdilik 1000 limit ile test edelim.
      final allRequests = await bloodRequestRepository.fetchAllActiveOnce(
        limit: 1000,
      );
      logger.i(
        "TopNearbyNotifier: fetchAllActiveOnce ${allRequests.length} aktif talep getirdi.",
      );

      if (allRequests.isEmpty) {
        logger.i("TopNearbyNotifier: Hiç aktif talep bulunamadı.");
        return [];
      }

      final List<BloodRequest> filteredRequests = [];
      for (var r in allRequests) {
        final isOwnRequest = r.creatorId == userId;
        final isActive =
            r.status ==
            'active'; // Zaten query ile filtrelenmiş olmalı ama garanti olsun.
        final canDonate =
            userBloodType == null ||
            BloodCompatibility.canDonateTo(userBloodType, r.bloodType);

        final shouldInclude = !isOwnRequest && isActive && canDonate;

        if (!shouldInclude) {
          String reason = "";
          if (isOwnRequest) reason += "Kendi talebi. ";
          if (!isActive) reason += "Aktif değil (${r.status}). ";
          if (!canDonate) {
            // If !canDonate is true, userBloodType is guaranteed to be non-null.
            reason +=
                "Kan uyumsuz (İstenen: ${r.bloodType}, Kullanıcı: $userBloodType). ";
          }
          // The 'else if (!canDonate && userBloodType == null)' block was removed
          // because if !canDonate is true, userBloodType cannot be null, making the condition always false.
          logger.d(
            "TopNearbyNotifier - Talep Atlandı: ID=${r.id}, Başlık='${r.title}'. Neden: $reason",
          );
        } else {
          filteredRequests.add(r);
        }
      }

      logger.i(
        "TopNearbyNotifier: Filtreleme sonrası ${filteredRequests.length} adet talep kaldı.",
      );

      if (filteredRequests.isEmpty) {
        logger.i(
          "TopNearbyNotifier: Filtrelenmiş uygun talep yok, boş liste dönülüyor.",
        );
        return [];
      }

      final bloodRequestService = ref.read(bloodRequestServiceProvider);
      final topNearbyWithDistance = bloodRequestService.sortAndGetTop3(
        filteredRequests,
        currentPosition,
        // count: 3, // Assuming the '3' is implicit in the method name or it's not configurable here
      );

      logger.i(
        "TopNearbyNotifier: sortAndGetTopN ${topNearbyWithDistance.length} adet sonuç döndürdü.",
      );
      if (topNearbyWithDistance.isNotEmpty) {
        topNearbyWithDistance.asMap().forEach((index, reqWithDist) {
          logger.d(
            "TopNearbyNotifier: Top ${index + 1}: ID=${reqWithDist.request.id}, Başlık='${reqWithDist.request.title}', Mesafe=${reqWithDist.distance.toStringAsFixed(2)}km, Talep Konumu: ${reqWithDist.request.location?.latitude},${reqWithDist.request.location?.longitude}",
          );
        });
      } else {
        logger.i("TopNearbyNotifier: sortAndGetTopN boş liste döndürdü.");
      }
      return topNearbyWithDistance;
    } catch (e, stack) {
      logger.e(
        "TopNearbyNotifier: build() metodunda (talepler işlenirken) hata oluştu.",
        error: e,
        stackTrace: stack,
      );
      throw Exception('Yakındaki talepler getirilirken hata oluştu: $e');
    }
  }

  /// Dışarıdan manuel yenileme için (örn: Pull-to-refresh)
  Future<void> refresh() async {
    logger.i("TopNearbyNotifier: Manuel refresh() çağrıldı.");
    // Notifier'ı invalidate etmek, build metodunun yeniden çalışmasını tetikler.
    ref.invalidateSelf();
    // State'i manuel olarak loading yapmak ve ardından veriyi çekmek de bir yöntem olabilirdi,
    // ancak invalidateSelf, Riverpod'ın kendi mekanizmasını kullanır.
    // build() metodu, bağımlılıklar (konum, auth) değiştiğinde zaten yeniden çalışacağı için,
    // bu refresh metodu özellikle kullanıcı etkileşimiyle tetiklenen yenilemeler için kullanılır.
    await future; // build() metodunun tamamlanmasını bekle (opsiyonel, UI'da anlık loading için)
  }
}
