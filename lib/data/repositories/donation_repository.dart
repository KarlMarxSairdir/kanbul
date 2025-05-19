// lib/data/repositories/donation_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Riverpod kod üretimi için
import 'package:riverpod/riverpod.dart'; // Ref için
import 'package:kan_bul/core/services/firestore_service.dart';

part 'donation_repository.g.dart'; // Kod üretimi için part direktifi

class DonationRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = logger;

  DonationRepository(this._firestore);

  CollectionReference get _donationsCollection =>
      _firestore.collection('donations');
  CollectionReference get _bloodRequestsCollection =>
      _firestore.collection('bloodRequests'); // Request count için

  /// Yeni bağış yanıtı oluşturur ve ilgili talebin yanıt sayısını artırır.
  Future<String> createDonationResponse({
    required String donorId,
    required String donorName, // Denormalized
    required String? donorBloodType, // Denormalized
    required String? donorPhotoUrl, // Denormalized
    required String requestId,
    required String requestCreatorId, // Denormalized
    String? message,
  }) async {
    _logger.i("DonationRepository: Yeni bağış yanıtı oluşturuluyor...");
    try {
      // Kullanıcının bu talebe daha önce yanıt verip vermediğini kontrol et
      final existingDonations =
          await _donationsCollection
              .where('donorId', isEqualTo: donorId)
              .where('requestId', isEqualTo: requestId)
              .limit(1) // Sadece bir tane bulmak yeterli
              .get();

      if (existingDonations.docs.isNotEmpty) {
        _logger.w(
          "Kullanıcı $donorId, $requestId talebine zaten yanıt vermiş. Yeni yanıt oluşturulmayacak.",
        );
        throw Exception('Bu talebe zaten bir yanıt verdiniz.');
      }

      final now = Timestamp.now();
      final donationRef = _donationsCollection.doc(); // Yeni ID al
      final requestRef = _bloodRequestsCollection.doc(requestId);

      final Map<String, dynamic> donationData = {
        'donorId': donorId,
        'donorName': donorName,
        'donorBloodType': donorBloodType,
        'donorPhotoUrl': donorPhotoUrl,
        'requestId': requestId,
        'requestCreatorId': requestCreatorId,
        'status': 'pending', // Yanıtlar pending başlar
        'respondedAt': now,
        'createdAt': now,
        'updatedAt': now,
        if (message != null && message.isNotEmpty) 'message': message,
      };
      donationData.removeWhere(
        (key, value) => value == null,
      ); // Transaction kullanarak iki yazma işlemini atomik yap
      await _firestore.runTransaction((transaction) async {
        // Önce talep belgesinin var olup olmadığını kontrol et
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          // Talep belgesi bulunamadı, hata fırlat
          throw Exception('Blood request not found: $requestId');
        }

        // 1. Donation belgesini oluştur
        transaction.set(donationRef, donationData);
        // 2. BloodRequest belgesindeki responseCount'u artır
        transaction.update(requestRef, {
          'responseCount': FieldValue.increment(1),
        });
      });

      _logger.i(
        "Bağış yanıtı başarıyla oluşturuldu ve talep güncellendi: ${donationRef.id}",
      );
      return donationRef.id;
    } catch (e, s) {
      _logger.e('Bağış yanıtı oluşturma hatası', error: e, stackTrace: s);
      if (e.toString().contains('Bu talebe zaten bir yanıt verdiniz.')) {
        rethrow;
      }
      throw Exception('Bağış yanıtı oluşturulurken bir hata oluştu: $e');
    }
  }

  /// Bağış yanıtının durumunu günceller.
  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    _logger.i(
      "DonationRepository: Bağış durumu güncelleniyor: $donationId -> $newStatus",
    );
    if (!['accepted', 'rejected', 'completed', 'pending'].contains(newStatus)) {
      throw ArgumentError("Geçersiz durum: $newStatus");
    }
    try {
      await _donationsCollection.doc(donationId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
        // Eğer tamamlandıysa completedDate eklenebilir
        if (newStatus == 'completed') 'completedDate': Timestamp.now(),
      });
    } catch (e, s) {
      _logger.e(
        'Bağış durumu ($newStatus) güncelleme hatası (ID: $donationId)',
        error: e,
        stackTrace: s,
      );
      throw Exception('Bağış durumu güncellenirken bir hata oluştu: $e');
    }
  }

  /// Bir kan talebi için olan bağış yanıtlarını dinleyen stream.
  Stream<QuerySnapshot> getRequestDonationsStream(
    String requestId, {
    String? statusFilter,
  }) {
    _logger.d(
      "DonationRepository: Getting donations stream for request $requestId, status: $statusFilter",
    );
    try {
      Query query = _donationsCollection
          .where('requestId', isEqualTo: requestId)
          .orderBy('respondedAt', descending: true); // En yeniden eskiye

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }
      return query.snapshots();
    } catch (e, s) {
      _logger.e(
        "Talep ($requestId) yanıtları stream hatası",
        error: e,
        stackTrace: s,
      );
      return Stream.error(Exception('Talep yanıtları alınamadı: $e'));
    }
  }

  /// Kullanıcının bağışlarını/yanıtlarını durumuna göre dinleyen stream.
  Stream<QuerySnapshot> getUserDonationsByStatusStream(
    String userId,
    String status,
  ) {
    _logger.d(
      "DonationRepository: Getting user donations stream for user $userId, status $status",
    );
    try {
      return _donationsCollection
          .where('donorId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('respondedAt', descending: true)
          .snapshots();
    } catch (e, s) {
      _logger.e(
        "Kullanıcı ($userId) bağışları ($status) stream hatası",
        error: e,
        stackTrace: s,
      );
      return Stream.error(Exception('Kullanıcı bağışları alınamadı: $e'));
    }
  }

  /// Kullanıcının tamamladığı bağış sayısını getirir.
  Future<int> getCompletedDonationCount(String userId) async {
    _logger.d(
      "DonationRepository: Getting completed donation count for user $userId",
    );
    try {
      final snapshot =
          await _donationsCollection
              .where('donorId', isEqualTo: userId)
              .where('status', isEqualTo: 'completed')
              .count() // count() ile sadece sayıyı alabiliriz, daha verimli
              .get();
      return snapshot.count ?? 0;
    } catch (e, s) {
      _logger.e(
        "Tamamlanan bağış sayısı getirme hatası",
        error: e,
        stackTrace: s,
      );
      // Hata durumunda 0 döndür
      return 0;
    }
  }

  /// ID'ye göre tekil bağış belgesi getirir
  Future<DocumentSnapshot?> getDonationById(String donationId) async {
    _logger.d("DonationRepository: ID'ye göre bağış getiriliyor: $donationId");
    try {
      final docSnapshot = await _donationsCollection.doc(donationId).get();
      return docSnapshot;
    } catch (e, s) {
      _logger.e(
        "Bağış getirme hatası (ID: $donationId)",
        error: e,
        stackTrace: s,
      );
      throw Exception('Bağış bilgisi alınamadı: $e');
    }
  }
}

// DonationRepository provider'ı - ADIM 2
@riverpod
DonationRepository donationRepository(Ref ref) {
  // Bağımlılıkları varsa burada ref.watch ile alınmalıdır.
  return DonationRepository(ref.watch(firestoreProvider));
}
