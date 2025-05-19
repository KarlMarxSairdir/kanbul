// lib/data/models/blood_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'blood_request_model.freezed.dart';
part 'blood_request_model.g.dart';

@freezed
class BloodRequest with _$BloodRequest {
  const BloodRequest._(); // Özel metotlar için
  const factory BloodRequest({
    // ID artık JSON'dan okunabilecek
    required String id, // fromSnapshot'ta eklendiği için required
    required String creatorId,
    required String creatorName,
    required String creatorRole,
    required String bloodType,
    required String title,
    required String description,
    required String hospitalName,
    required int unitsNeeded,
    required int urgencyLevel,

    // Nullable alanlar
    @GeoPointConverter() GeoPoint? location,
    @TimestampConverter() Timestamp? createdAt,
    @TimestampConverter() Timestamp? updatedAt,
    String? patientInfo,
    String? contactPhone,

    // Gerekli alanlar (varsayılan değerlerle)
    @Default('active') String status,
    @Default(0) int responseCount,
    @Default([]) List<String> acceptedDonorIds,
  }) = _BloodRequest;

  // fromSnapshot metodu: Firestore'dan gelen veriyi modele dönüştürür
  factory BloodRequest.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      // Data yoksa veya boşsa, minimal bir model döndür veya hata fırlat
      // Bu durumda hata fırlatmak daha mantıklı olabilir
      throw Exception(
        "BloodRequest.fromSnapshot: Snapshot data is null for ID ${snapshot.id}",
      );
    }
    // Firestore ID'sini veriye ekle
    data['id'] = snapshot.id;
    try {
      // fromJson fabrika metodunu kullanarak modeli oluştur
      return BloodRequest.fromJson(data);
    } catch (e) {
      // Hata fırlatma
      throw Exception("Failed to parse BloodRequest data: $e");
    }
  }

  // fromJson fabrika metodu: JSON verisini modele dönüştürür (Freezed için gerekli)
  factory BloodRequest.fromJson(Map<String, dynamic> json) =>
      _$BloodRequestFromJson(json);

  // toJson metodu Freezed tarafından otomatik olarak oluşturulur.
  // Elle yazmaya gerek yok.

  // Hesaplanan özellik: Talep karşılandı mı?
  bool get isFulfilled =>
      unitsNeeded > 0 && acceptedDonorIds.length >= unitsNeeded;
}
