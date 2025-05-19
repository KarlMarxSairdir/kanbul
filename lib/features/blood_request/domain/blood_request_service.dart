import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/utils/location_utils.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/features/blood_request/domain/models/request_with_distance.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/utils/blood_compatibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'blood_request_service.g.dart';

/// Kan taleplerine ait iş mantığı işlemlerini sağlayan hizmet sınıfı.
/// Repository'den farklı olarak, veritabanı işlemleri yerine hesaplama, filtreleme
/// gibi domain işlemlerini yürütür.
class BloodRequestService {
  /// Kan taleplerini mesafeye göre sıralar ve en yakın 3 talebi döndürür
  List<RequestWithDistance> sortAndGetTop3(
    List<BloodRequest> requests,
    Position position,
  ) {
    if (requests.isEmpty) {
      return [];
    }

    // Mesafe hesaplaması yap
    final withDistance =
        requests.where((request) => request.location != null).map((request) {
          final distance = LocationUtils.calculateDistanceInKm(
            position.latitude,
            position.longitude,
            request.location!.latitude,
            request.location!.longitude,
          );
          return RequestWithDistance(request: request, distance: distance);
        }).toList();

    // Mesafeye göre sırala
    withDistance.sort((a, b) => a.distance.compareTo(b.distance));

    // En yakın 3 talebi al
    return withDistance.take(3).toList();
  }

  /// Kan uyumluluğuna göre filtreleme yapar
  List<BloodRequest> filterByCompatibility(
    List<BloodRequest> requests,
    String donorBloodType,
  ) {
    return requests.where((req) {
      // Eşleşen kan grupları kontrolü burada yapılır
      return BloodCompatibility.canDonateTo(donorBloodType, req.bloodType);
    }).toList();
  }
}

/// BloodRequestService provider'ı - @riverpod ile yeniden yazıldı
@riverpod
BloodRequestService bloodRequestService(Ref ref) {
  return BloodRequestService();
}
