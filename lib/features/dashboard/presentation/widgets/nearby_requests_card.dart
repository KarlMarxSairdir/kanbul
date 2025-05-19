import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/features/blood_request/presentation/providers/top_nearby_notifier.dart';
import 'package:kan_bul/features/blood_request/domain/models/request_with_distance.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:go_router/go_router.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart'; // Geolocator might not be needed directly here anymore if position is not constructed

/// Yakındaki Kan Taleplerini gösteren kart widget'ı
/// Riverpod ile güncel talepleri izler ve yakınlığa göre listeler
class NearbyRequestsCard extends ConsumerWidget {
  final bool isLoadingLocation;

  const NearbyRequestsCard({super.key, required this.isLoadingLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcının kan grubunu al
    final userBloodType = ref.watch(
      authStateNotifierProvider.select(
        (authState) => authState.user?.profileData.bloodType,
      ),
    );

    // Kullanıcı kan grubunu göster
    logger.d("NearbyRequestsCard: Kullanıcı kan grubu: $userBloodType");

    // Kullanıcı bilgisini Riverpod ile al
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;

    // Kullanıcı yoksa hata göster
    if (user == null) {
      return _buildErrorCard(
        context,
        ref,
        () => ref.invalidate(topNearbyNotifierProvider),
      );
    }

    // Kullanıcının konumu yoksa uyarı göster
    final userLocation = user.profileData.location;
    final canShowNearbyRequests = !isLoadingLocation && userLocation != null;

    logger.d(
      "NearbyRequestsCard Build: isLoadingLocation=$isLoadingLocation, "
      "hasLocation=${userLocation != null}",
    );

    if (isLoadingLocation) {
      return _buildLoadingCard(context);
    }

    if (!canShowNearbyRequests) {
      return _buildNoLocationCard(context);
    }

    // Global provider'ı kullan
    final topNearbyRequestsAsyncValue = ref.watch(topNearbyNotifierProvider);

    // The explicit call to topNearbyNotifierProvider.notifier.run(...) is removed.
    // TopNearbyNotifier is now expected to handle its data fetching reactively
    // based on its dependencies (e.g., user location, user ID).

    // AsyncValue state'ine göre uygun UI'ı göster
    return topNearbyRequestsAsyncValue.when(
      loading: () => _buildLoadingCard(context),
      error: (error, stack) {
        logger.e("NearbyRequestsCard Error:", error: error, stackTrace: stack);
        return _buildErrorCard(
          context,
          ref,
          () => ref.invalidate(topNearbyNotifierProvider),
        );
      },
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyCard(context);
        }

        return _buildRequestsCard(context, requests);
      },
    );
  }

  /// Ana talep kartı yapısı
  Widget _buildRequestsCard(
    BuildContext context,
    List<RequestWithDistance> requests,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Liste bölümü
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: requests.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final requestWithDistance = requests[index];
                final request = requestWithDistance.request;
                final distance = requestWithDistance.distance;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    request.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDistance(distance),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text(
                      request.bloodType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.createdAt != null
                            ? timeago.format(
                              request.createdAt!.toDate(),
                              locale: 'tr',
                            )
                            : 'Bilinmiyor',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    context.push(
                      '${AppRoutes.bloodRequestDetail}/${request.id}',
                    );
                  },
                );
              },
            ),
          ),

          // Haritada görüntüleme buton bölümü
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.map),
                icon: const Icon(Icons.map),
                label: const Text('Haritada Gör'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Konum yükleniyor durumunda gösterilen kart
  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Liste öğeleri shimmer ile
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder:
                  (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0) const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,
                          ),
                          title: Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: 120,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          trailing: Container(
                            width: 60,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),

          // Buton placeholder
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Konum bilgisi yoksa gösterilen kart
  Widget _buildNoLocationCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 36,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Konum bilgisi alınamadı',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Yakındaki talepleri görmek için konumunuzu paylaşmalısınız.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Konum İzni Ver'),
            ),
          ],
        ),
      ),
    );
  }

  /// Hata durumunda gösterilen kart
  Widget _buildErrorCard(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onRefresh,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 36,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Bir sorun oluştu',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Yakındaki talepler yüklenirken bir hata oluştu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Yenile')),
          ],
        ),
      ),
    );
  }

  /// Talep bulunamadığında gösterilen kart
  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon ve mesaj
            Icon(
              Icons.search_off,
              size: 36,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Çevrenizde şu anda aktif kan talebi bulunmuyor.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Haritada görüntüleme butonu
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.map),
                icon: const Icon(Icons.map),
                label: const Text('Haritada Gör'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mesafe bilgisini formatla
  String _formatDistance(double distanceInKm) {
    if (distanceInKm == double.infinity) {
      return 'Mesafe hesaplanamıyor';
    }

    if (distanceInKm < 1) {
      // 1 km'den az ise metre cinsinden göster
      final meters = (distanceInKm * 1000).round();
      return '$meters metre';
    } else {
      // 1 km'den fazla ise km cinsinden göster (1 ondalık basamak)
      final formatter = NumberFormat('#,##0.0', 'tr_TR');
      return '${formatter.format(distanceInKm)} km';
    }
  }
}
