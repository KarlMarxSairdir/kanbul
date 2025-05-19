// lib/data/repositories/blood_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/features/blood_request/domain/i_blood_request_repository.dart';
import 'package:kan_bul/core/utils/location_utils.dart';
import 'package:kan_bul/core/utils/blood_compatibility.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/services/firestore_service.dart'; // firestoreProvider için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated logger import

part 'blood_request_repository.g.dart';

/// Kan talepleri için FirebaseFirestore tabanlı repository implementasyonu
class BloodRequestRepository implements IBloodRequestRepository {
  final FirebaseFirestore _firestore;

  BloodRequestRepository(this._firestore);

  // Koleksiyon referansı
  late final CollectionReference _bloodRequestsCollection = _firestore
      .collection('bloodRequests');

  /// Yeni kan talebi oluşturur
  @override
  Future<String> createBloodRequest(BloodRequest request) async {
    logger.i("BloodRequestRepository: Yeni kan talebi oluşturuluyor...");
    try {
      final now = Timestamp.now();
      final Map<String, dynamic> requestData = {
        'creatorId': request.creatorId,
        'creatorName': request.creatorName,
        'creatorRole': request.creatorRole,
        'title': request.title,
        'description': request.description,
        'bloodType': request.bloodType,
        'unitsNeeded': request.unitsNeeded,
        'urgencyLevel': request.urgencyLevel,
        'location': request.location,
        'status': request.status,
        'responseCount': request.responseCount,
        'createdAt': now,
        'updatedAt': now,
        if (request.hospitalName != null) 'hospitalName': request.hospitalName,
        if (request.patientInfo != null) 'patientInfo': request.patientInfo,
        if (request.contactPhone != null) 'contactPhone': request.contactPhone,
      };
      requestData.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty),
      );

      final DocumentReference docRef = await _bloodRequestsCollection.add(
        requestData,
      );
      logger.i("Kan talebi başarıyla oluşturuldu: ${docRef.id}");
      return docRef.id;
    } catch (e, s) {
      logger.e('Kan talebi oluşturma hatası', error: e, stackTrace: s);
      throw Exception('Kan talebi oluşturulurken bir hata oluştu: $e');
    }
  }

  /// Kan talebini ID'ye göre getirir (Tek seferlik okuma)
  Future<DocumentSnapshot?> getBloodRequestById(String requestId) async {
    logger.d("BloodRequestRepository: getBloodRequestById: $requestId");
    try {
      final doc = await _bloodRequestsCollection.doc(requestId).get();
      return doc.exists ? doc : null;
    } catch (e, s) {
      logger.e('Talep detayı getirme hatası', error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Future<BloodRequest?> getById(String id) async {
    logger.d("BloodRequestRepository: getById: $id");
    try {
      final doc = await getBloodRequestById(id);
      if (doc == null || !doc.exists) return null;
      return BloodRequest.fromSnapshot(doc);
    } catch (e, s) {
      logger.e('Talep detayı getirme hatası', error: e, stackTrace: s);
      return null;
    }
  }

  /// Kan talebini ID'ye göre dinler (Real-time)
  Stream<DocumentSnapshot> getBloodRequestStreamById(String requestId) {
    logger.d("BloodRequestRepository: getBloodRequestStreamById: $requestId");
    try {
      return _bloodRequestsCollection.doc(requestId).snapshots();
    } catch (e, s) {
      logger.e('Talep detayı stream hatası', error: e, stackTrace: s);
      return Stream.error(Exception('Talep detayı stream alınamadı: $e'));
    }
  }

  @override
  Stream<BloodRequest> watchById(String id) {
    logger.d("BloodRequestRepository: watchById: $id");
    return getBloodRequestStreamById(
      id,
    ).map((snapshot) => BloodRequest.fromSnapshot(snapshot));
  }

  /// Tüm aktif kan taleplerini TEK SEFERLIK çeker (Stream değil, Future).
  /// Yakındaki talepler için ilk veri kaynağı olarak kullanılabilir.
  @override
  Future<List<BloodRequest>> fetchAllActiveOnce({int? limit}) async {
    logger.d(
      "BloodRequestRepository: fetchAllActiveOnce çağrıldı. Limit: ${limit ?? 'Yok'}",
    );
    try {
      Query query = _bloodRequestsCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final requests =
          querySnapshot.docs
              .map((doc) => BloodRequest.fromSnapshot(doc))
              .toList();
      logger.i(
        "BloodRequestRepository: fetchAllActiveOnce ${requests.length} aktif talep getirdi.",
      );
      return requests;
    } catch (e, s) {
      logger.e("fetchAllActiveOnce hata", error: e, stackTrace: s);
      throw Exception('Aktif talepler (tek seferlik) alınamadı: $e');
    }
  }

  /// Helper stream for active blood requests (private)
  Stream<QuerySnapshot> _getAllActiveBloodRequestsStream({int limit = 20}) {
    logger.d(
      "BloodRequestRepository: Getting ALL active blood requests stream with limit: $limit",
    );
    try {
      return _bloodRequestsCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e, s) {
      logger.e("Tüm aktif talepler stream hatası", error: e, stackTrace: s);
      return Stream.error(Exception('Tüm aktif talepler alınamadı: $e'));
    }
  }

  /// Tüm aktif kan taleplerini SÜREKLİ dinler (Stream).
  @override
  Stream<List<BloodRequest>> watchAllActive({int limit = 20}) {
    logger.d("BloodRequestRepository: watchAllActive with limit: $limit");
    return _bloodRequestsCollection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((querySnapshot) {
          final requests =
              querySnapshot.docs
                  .map((doc) => BloodRequest.fromSnapshot(doc))
                  .toList();
          logger.d(
            "BloodRequestRepository: watchAllActive stream ${requests.length} talep yaydı.",
          );
          return requests;
        })
        .handleError((error, stackTrace) {
          logger.e(
            "watchAllActive stream hata",
            error: error,
            stackTrace: stackTrace,
          );
          throw error;
        });
  }

  /// Belirli bir kullanıcının taleplerini durumuna göre dinleyen stream.
  Stream<QuerySnapshot> getUserRequestsByStatusStream(
    String userId,
    String status,
  ) {
    logger.d(
      "BloodRequestRepository: Getting user requests stream for user $userId, status $status",
    );
    try {
      return _bloodRequestsCollection
          .where('creatorId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e, s) {
      logger.e(
        "Kullanıcı ($userId) talepleri ($status) stream hatası",
        error: e,
        stackTrace: s,
      );
      return Stream.error(Exception('Kullanıcı talepleri alınamadı: $e'));
    }
  }

  @override
  Stream<List<BloodRequest>> watchUserRequestsByStatus(
    String userId,
    String status,
  ) {
    logger.d(
      "BloodRequestRepository: watchUserRequestsByStatus: user $userId, status $status",
    );
    return getUserRequestsByStatusStream(userId, status).map(
      (querySnapshot) =>
          querySnapshot.docs
              .map((doc) => BloodRequest.fromSnapshot(doc))
              .toList(),
    );
  }

  /// Belirli bir lokasyonun etrafındaki aktif kan taleplerini getirir (Client-side filtreleme)
  Stream<List<DocumentSnapshot>> getNearbyActiveBloodRequestsStream(
    GeoPoint center,
    double radiusInKm,
  ) {
    logger.i(
      "BloodRequestRepository: Getting nearby active blood requests stream - Center: (${center.latitude}, ${center.longitude}), Radius: ${radiusInKm}km",
    );
    try {
      return _getAllActiveBloodRequestsStream().map((snapshot) {
        logger.d(
          "Yakın talep filtreleniyor. Toplam aktif talep sayısı: ${snapshot.docs.length}",
        );

        final filteredDocs = <DocumentSnapshot>[];

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>?;

            if (data == null) {
              logger.w("Talep verisi null: ${doc.id}");
              continue;
            }

            final location = data['location'];
            if (location == null) {
              logger.w("Talep konumu eksik: ${doc.id}");
              continue;
            }

            if (location is! GeoPoint) {
              logger.w(
                "Talep konumu GeoPoint değil: ${doc.id}, Tip: ${location.runtimeType}",
              );
              continue;
            }

            final double distance = LocationUtils.calculateDistanceInKm(
              center.latitude,
              center.longitude,
              location.latitude,
              location.longitude,
            );

            logger.d(
              "Talep ID: ${doc.id}, Uzaklık: ${distance.toStringAsFixed(2)}km (Limit: ${radiusInKm}km)",
            );

            if (distance <= radiusInKm) {
              logger.d(
                "Yakında bir talep bulundu! ID: ${doc.id}, Uzaklık: ${distance.toStringAsFixed(2)}km",
              );
              filteredDocs.add(doc);
            }
          } catch (e, s) {
            logger.w(
              "Talep filtreleme hatası: ${doc.id}",
              error: e,
              stackTrace: s,
            );
          }
        }

        logger.i(
          "Yakındaki talep sayısı: ${filteredDocs.length}/${snapshot.docs.length} (${radiusInKm}km radius)",
        );
        return filteredDocs;
      });
    } catch (e, s) {
      logger.e("Yakındaki talepler getirme hatası", error: e, stackTrace: s);
      return Stream.error(Exception('Yakındaki talepler alınamadı: $e'));
    }
  }

  @override
  Stream<List<BloodRequest>> watchNearbyActive({
    required GeoPoint center,
    required double radiusKm,
  }) {
    logger.d("BloodRequestRepository: watchNearbyActive");
    return getNearbyActiveBloodRequestsStream(
      center,
      radiusKm,
    ).map((docs) => docs.map((doc) => BloodRequest.fromSnapshot(doc)).toList());
  }

  /// Kan talebini günceller
  Future<void> updateBloodRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    logger.i("BloodRequestRepository: Talep güncelleniyor: $requestId");
    try {
      data['updatedAt'] = Timestamp.now(); // Güncelleme zamanı
      await _bloodRequestsCollection.doc(requestId).update(data);
    } catch (e, s) {
      logger.e(
        'Kan talebi güncelleme hatası (ID: $requestId)',
        error: e,
        stackTrace: s,
      );
      throw Exception('Kan talebi güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) {
    logger.d("BloodRequestRepository: update: $id");
    return updateBloodRequest(id, data);
  }

  /// Kan talebinin durumunu günceller (örn. kapatma/iptal etme)
  Future<void> updateBloodRequestStatus(
    String requestId,
    String newStatus,
  ) async {
    logger.i(
      "BloodRequestRepository: Talep durumu güncelleniyor: $requestId -> $newStatus",
    );
    if (!['fulfilled', 'canceled', 'active'].contains(newStatus)) {
      throw ArgumentError("Geçersiz durum: $newStatus");
    }
    try {
      await _bloodRequestsCollection.doc(requestId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });
    } catch (e, s) {
      logger.e(
        'Talep durumu ($newStatus) güncelleme hatası (ID: $requestId)',
        error: e,
        stackTrace: s,
      );
      throw Exception('Talep durumu güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> updateStatus(String id, String status) {
    logger.d("BloodRequestRepository: updateStatus: $id to $status");
    return updateBloodRequestStatus(id, status);
  }

  /// Belirli bir kan grubuna sahip bağışçının verebileceği aktif kan taleplerini getirir
  Stream<QuerySnapshot> getCompatibleActiveRequestsStream(
    String donorBloodType, {
    int limit = 20,
  }) {
    logger.i(
      "BloodRequestRepository: Getting compatible active blood requests for donor type: $donorBloodType with limit: $limit",
    );
    try {
      final compatibleTypes = BloodCompatibility.getCompatibleRecipientGroups(
        donorBloodType,
      );
      if (compatibleTypes.isEmpty) {
        logger.w("Bilinmeyen kan grubu veya uyumlu tip yok: $donorBloodType");
        return _bloodRequestsCollection.limit(0).snapshots();
      }

      return _bloodRequestsCollection
          .where('status', isEqualTo: 'active')
          .where('bloodType', whereIn: compatibleTypes)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e, s) {
      logger.e("Uyumlu talepler stream hatası", error: e, stackTrace: s);
      return Stream.error(Exception('Uyumlu talepler alınamadı: $e'));
    }
  }

  @override
  Stream<List<BloodRequest>> watchCompatibleActive(
    String donorBloodType, {
    int limit = 20,
  }) {
    logger.d(
      "BloodRequestRepository: watchCompatibleActive for donor type: $donorBloodType",
    );
    return getCompatibleActiveRequestsStream(donorBloodType, limit: limit).map(
      (querySnapshot) =>
          querySnapshot.docs
              .map((doc) => BloodRequest.fromSnapshot(doc))
              .toList(),
    );
  }

  /// Belirli bir kan grubuna sahip bağışçının verebileceği ve yakındaki aktif kan taleplerini getirir
  Stream<List<DocumentSnapshot>> getCompatibleNearbyActiveRequestsStream(
    String donorBloodType,
    GeoPoint center,
    double radiusInKm,
  ) {
    logger.i(
      "BloodRequestRepository: Getting compatible nearby active requests - BloodType: $donorBloodType, Center: (${center.latitude}, ${center.longitude}), Radius: ${radiusInKm}km",
    );
    try {
      return getCompatibleActiveRequestsStream(donorBloodType).map((snapshot) {
        logger.d(
          "Uyumlu yakın talep filtreleniyor. Toplam uyumlu talep: ${snapshot.docs.length}",
        );

        final filteredDocs = <DocumentSnapshot>[];

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>?;

            if (data == null) {
              logger.w("Talep verisi null: ${doc.id}");
              continue;
            }

            final location = data['location'];
            if (location == null) {
              logger.w("Talep konumu eksik: ${doc.id}");
              continue;
            }

            if (location is! GeoPoint) {
              logger.w(
                "Talep konumu GeoPoint değil: ${doc.id}, Tip: ${location.runtimeType}",
              );
              continue;
            }

            final double distance = LocationUtils.calculateDistanceInKm(
              center.latitude,
              center.longitude,
              location.latitude,
              location.longitude,
            );

            logger.d(
              "Uyumlu Talep ID: ${doc.id}, Uzaklık: ${distance.toStringAsFixed(2)}km (Limit: ${radiusInKm}km)",
            );

            if (distance <= radiusInKm) {
              logger.d(
                "Yakında uyumlu talep bulundu! ID: ${doc.id}, Uzaklık: ${distance.toStringAsFixed(2)}km",
              );
              filteredDocs.add(doc);
            }
          } catch (e, s) {
            logger.w(
              "Uyumlu talep filtreleme hatası: ${doc.id}",
              error: e,
              stackTrace: s,
            );
          }
        }

        logger.i(
          "Yakındaki uyumlu talep sayısı: ${filteredDocs.length}/${snapshot.docs.length} (${radiusInKm}km radius)",
        );
        return filteredDocs;
      });
    } catch (e, s) {
      logger.e(
        "Yakındaki uyumlu talepler getirme hatası",
        error: e,
        stackTrace: s,
      );
      return Stream.error(Exception('Yakındaki uyumlu talepler alınamadı: $e'));
    }
  }

  @override
  Stream<List<BloodRequest>> watchCompatibleNearbyActive({
    required String donorBloodType,
    required GeoPoint center,
    required double radiusKm,
  }) {
    logger.d("BloodRequestRepository: watchCompatibleNearbyActive");
    return getCompatibleNearbyActiveRequestsStream(
      donorBloodType,
      center,
      radiusKm,
    ).map((docs) => docs.map((doc) => BloodRequest.fromSnapshot(doc)).toList());
  }

  /// Yakındaki aktif kan taleplerini limitle göstermek için stream
  Stream<QuerySnapshot> getNearbyAndActiveRequestsStream({int limit = 10}) {
    logger.d(
      "BloodRequestRepository: Getting nearby active blood requests with limit: $limit",
    );
    try {
      return _bloodRequestsCollection
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e, s) {
      logger.e("Yakındaki talepler stream hatası", error: e, stackTrace: s);
      return Stream.error(Exception('Yakındaki talepler alınamadı: $e'));
    }
  }
}

@riverpod
IBloodRequestRepository bloodRequestRepository(Ref ref) {
  // Updated Ref type
  return BloodRequestRepository(ref.watch(firestoreProvider));
}

@riverpod
Stream<List<BloodRequest>> allActiveBloodRequests(Ref ref, {int limit = 300}) {
  final repo = ref.watch(bloodRequestRepositoryProvider);
  return repo.watchAllActive(limit: limit);
}
