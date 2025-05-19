// lib/features/blood_request/domain/i_blood_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';

/// Kan talepleri için soyut repository arayüzü
abstract class IBloodRequestRepository {
  /// Yeni kan talebi oluşturur
  Future<String> createBloodRequest(BloodRequest request);

  /// ID'ye göre kan talebi detayını getirir
  Future<BloodRequest?> getById(String id);

  /// ID'ye göre kan talebini izler (stream olarak)
  Stream<BloodRequest> watchById(String id);

  /// Tüm aktif kan taleplerini izler
  Stream<List<BloodRequest>> watchAllActive({int limit = 20});

  /// Belirli bir bölgedeki aktif kan taleplerini izler
  Stream<List<BloodRequest>> watchNearbyActive({
    required GeoPoint center,
    required double radiusKm,
  });

  /// Kan talebini günceller
  Future<void> update(String id, Map<String, dynamic> data);

  /// Kan talebi durumunu günceller
  Future<void> updateStatus(String id, String status);

  /// Belirli bir kullanıcının duruma göre taleplerini izler
  Stream<List<BloodRequest>> watchUserRequestsByStatus(
    String userId,
    String status,
  );

  /// Kan grubuna göre uyumlu aktif talepleri izler
  Stream<List<BloodRequest>> watchCompatibleActive(
    String donorBloodType, {
    int limit = 20,
  });

  /// Kan grubuna göre uyumlu ve yakındaki aktif talepleri izler
  Stream<List<BloodRequest>> watchCompatibleNearbyActive({
    required String donorBloodType,
    required GeoPoint center,
    required double radiusKm,
  });

  // YENİ EKLENEN METOT TANIMI:
  /// Tüm aktif kan taleplerini tek seferlik çeker.
  Future<List<BloodRequest>> fetchAllActiveOnce({int? limit});
}
