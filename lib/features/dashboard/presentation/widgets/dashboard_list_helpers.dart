import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/features/blood_request/domain/models/request_with_distance.dart';
import 'package:kan_bul/routes/app_routes.dart';

/// Tüm liste widget'ları tarafından paylaşılan yardımcı metotlar

// Talep liste öğesi oluşturur
Widget buildRequestListItem(
  BuildContext context, {
  required BloodRequest request,
  required bool isUserRequest,
  double? distance,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Kan grubu için avatar
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Text(
          request.bloodType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Talep başlığı
      title: Text(request.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      // Alt başlık: Kullanıcı talebi ise hastane adı, değilse mesafe göster
      subtitle:
          isUserRequest
              ? Text(
                request.hospitalName ?? 'Hastane bilgisi yok',
                style: GoogleFonts.nunito(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : Text(
                formatDistance(distance ?? double.infinity),
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
              ),
      // Oluşturulma zamanı ve ileri ok ikonu
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              request.createdAt != null
                  ? timeago.format(request.createdAt!.toDate(), locale: 'tr')
                  : 'Bilinmiyor',
              style: Theme.of(context).textTheme.bodySmall,
              overflow:
                  TextOverflow
                      .ellipsis, // Ekstra güvenlik için taşma durumunda ... göster
              maxLines: 1, // Tek satırda kalmasını sağla
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      // Detay sayfasına yönlendirme
      onTap: () {
        if (request.id.isNotEmpty) {
          context.pushNamed(
            AppRoutes.bloodRequestDetail,
            pathParameters: {'requestId': request.id},
          );
        }
      },
    ),
  );
}

// Yükleniyor listesi gösterir
Widget buildLoadingList() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
                    leading: const CircleAvatar(backgroundColor: Colors.white),
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
  );
}

// Konum izni yoksa gösterilecek kart
Widget buildNoLocationCard(BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Konum İzni Ver'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

// Hata durumunda gösterilecek widget
Widget buildErrorWidget(
  BuildContext context,
  WidgetRef ref,
  String message,
  VoidCallback onRetry,
) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir sorun oluştu',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Yenile')),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

// Boş liste durumunda gösterilecek widget
Widget buildEmptyListWidget(
  BuildContext context,
  String message, {
  required bool isUserList,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(isUserList ? 16.0 : AppSizes.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUserList
                ? Icons.playlist_add_check_circle_outlined
                : Icons.search_off,
            size: 40,
            color: Theme.of(
              context,
            ).colorScheme.secondary.withAlpha((0.7 * 255).round()),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (isUserList) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Yeni Talep Oluştur'),
              onPressed: () {
                context.push(AppRoutes.createBloodRequest);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusLarge,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ListView oluşturur
Widget buildListView(
  BuildContext context,
  List<dynamic> items, // Liste dinamik tipte olacak
  Position? currentUserPosition,
  bool isUserList,
) {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXSmall),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      BloodRequest request;
      double? distance; // Mesafe sadece yakındaki için

      if (item is RequestWithDistance) {
        request = item.request;
        distance = item.distance; // Provider'dan gelen hesaplanmış mesafe
      } else if (item is BloodRequest) {
        request = item;
        distance = null; // Aktif taleplerim için mesafe yok
      } else {
        return const SizedBox.shrink(); // Beklenmeyen tip
      }

      // Liste öğesini oluştur
      return buildRequestListItem(
        context,
        request: request,
        isUserRequest: isUserList,
        // Yakındaki sekme için mesafeyi doğrudan kullan, diğerleri için null
        distance: isUserList ? null : distance,
      );
    },
  );
}

// Mesafe bilgisini formatla
String formatDistance(double distanceInKm) {
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

// RequestWithDistance için kart Widget'ı
Widget buildRequestWithDistanceCard(
  BuildContext context,
  RequestWithDistance requestWithDistance,
) {
  return Card(
    child: ListTile(
      title: Text(requestWithDistance.request.title),
      subtitle: Text(formatDistance(requestWithDistance.distance)),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Text(
          requestWithDistance.request.bloodType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
