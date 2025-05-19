import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/data/models/donation_center_model.dart';
import 'package:kan_bul/core/utils/logger.dart' as app_logger;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/services/firestore_service.dart'; // firestoreProvider için
import 'package:kan_bul/core/utils/location_utils.dart'; // Eğer getNearbyDonationCentersFromFirestore içinde kullanılacaksa
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'donation_center_repository.g.dart';

abstract class IDonationCenterRepository {
  Future<List<DonationCenterModel>> getIzmirDonationCentersFromApi();
  // Eğer API verisini Firestore'a da kaydetmek istiyorsanız bu metot kalabilir:
  Future<void> fetchAndSaveIzmirDonationCentersToFirestore();
  // Firestore'dan okuma metotları, eğer kullanılacaksa:
  Future<List<DonationCenterModel>> getAllDonationCentersFromFirestore();
  Future<List<DonationCenterModel>> getNearbyDonationCentersFromFirestore({
    required GeoPoint userLocation,
    double radiusKm = 30.0,
    int limit = 20,
  });
}

class DonationCenterRepository implements IDonationCenterRepository {
  final FirebaseFirestore _firestore;
  final _logger = app_logger.logger;
  final String _izmirApiUrl =
      "https://openapi.izmir.bel.tr/api/ibb/cbs/kanmerkezleri";

  DonationCenterRepository(this._firestore);

  CollectionReference get _donationCentersCollection =>
      _firestore.collection('donationCenters'); // Firestore için koleksiyon adı

  @override
  Future<List<DonationCenterModel>> getIzmirDonationCentersFromApi() async {
    _logger.i(
      "DonationCenterRepository: Fetching Izmir donation centers directly from API...",
    );
    try {
      final response = await http.get(Uri.parse(_izmirApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(
          utf8.decode(
            response.bodyBytes,
          ), // Türkçe karakterler için UTF-8 decode
        );

        // API yanıtındaki anahtar 'onemliyer' olarak güncellendi
        if (decodedData.containsKey('onemliyer') &&
            decodedData['onemliyer'] is List) {
          final List<dynamic> records =
              decodedData['onemliyer'] as List<dynamic>;

          final centers =
              records
                  .map((recordJson) {
                    try {
                      // Modeldeki API'ye özel fromJson metodunu kullan
                      return DonationCenterModel.fromIzmirApiJson(
                        recordJson as Map<String, dynamic>,
                      );
                    } catch (e, s) {
                      _logger.e(
                        "Error parsing a donation center record from Izmir API. Record: $recordJson",
                        error: e,
                        stackTrace: s,
                      );
                      return null; // Hatalı kaydı atla
                    }
                  })
                  .whereType<DonationCenterModel>()
                  .toList(); // Sadece başarılı parse edilenleri al

          _logger.i(
            "Successfully fetched ${centers.length} donation centers from Izmir API.",
          );
          return centers;
        } else {
          _logger.e(
            "Izmir API response does not contain 'onemliyer' list or it's not a list. Response (first 200 chars): ${decodedData.toString().substring(0, decodedData.toString().length > 200 ? 200 : decodedData.toString().length)}",
          );
          throw Exception("İzmir API'sinden beklenen formatta veri alınamadı.");
        }
      } else {
        _logger.e(
          "Failed to load donation centers from Izmir API. Status code: ${response.statusCode}, Body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}",
        );
        throw Exception(
          "İzmir kan merkezleri API'den yüklenemedi. Hata kodu: ${response.statusCode}",
        );
      }
    } catch (e, s) {
      _logger.e(
        "Error fetching donation centers from Izmir API",
        error: e,
        stackTrace: s,
      );
      // Kullanıcıya daha anlaşılır bir hata vermek için yeniden fırlatılabilir
      // veya burada null/boş liste döndürülebilir.
      throw Exception(
        "İzmir kan merkezleri API'den alınırken bir hata oluştu: $e",
      );
    }
  }

  // API'den çekip Firestore'a kaydetmek isterseniz bu metodu kullanabilirsiniz
  @override
  Future<void> fetchAndSaveIzmirDonationCentersToFirestore() async {
    _logger.i(
      "DonationCenterRepository: Fetching Izmir donation centers from API to save to Firestore...",
    );
    try {
      final List<DonationCenterModel> apiCenters =
          await getIzmirDonationCentersFromApi();

      if (apiCenters.isEmpty) {
        _logger.w(
          "No donation center data received from API. Nothing will be saved to Firestore.",
        );
        return;
      }

      WriteBatch batch = _firestore.batch();
      int batchCounter = 0;
      int totalProcessed = 0;

      for (var centerModelFromApi in apiCenters) {
        // API'den gelen modelin ID'sini Firestore için belge ID'si olarak kullan
        final DocumentReference centerDocRef = _donationCentersCollection.doc(
          centerModelFromApi.id,
        );

        // Modelin toJson() metodu Firestore'a uygun olmalı
        batch.set(
          centerDocRef,
          centerModelFromApi
              .toJson(), // createdAt ve updatedAt Firestore'a yazılırken set edilecek
          SetOptions(merge: true), // Var olanı güncelle, olmayanı oluştur
        );
        batchCounter++;
        totalProcessed++;

        // Firestore batch limitine yaklaşınca commit et
        if (batchCounter >= 450) {
          // Limit 500, biraz pay bırakalım
          await batch.commit();
          batch = _firestore.batch(); // Yeni batch başlat
          _logger.d(
            "$batchCounter centers added to Firestore batch and committed. Total processed: $totalProcessed",
          );
          batchCounter = 0; // Sayacı sıfırla
        }
      }
      // Kalan işlemleri commit et
      if (batchCounter > 0) {
        await batch.commit();
        _logger.d(
          "Remaining $batchCounter centers added to Firestore batch and committed. Total processed: $totalProcessed",
        );
      }

      _logger.i(
        "Total $totalProcessed donation centers from API successfully saved/updated in Firestore!",
      );
    } catch (e, s) {
      _logger.e(
        "Error fetching and saving Izmir donation centers to Firestore",
        error: e,
        stackTrace: s,
      );
      // Bu hatayı yukarıya fırlatmak, çağıranın haberdar olmasını sağlar
      // rethrow;
    }
  }

  // Bu metot artık kullanılmayacaksa veya farklı bir JSON yapısı içinse kaldırılabilir/güncellenebilir.
  // Future<void> processDonationCentersFromJson(String jsonData) async { ... }

  // Firestore'dan tüm merkezleri okuma (Eğer Firestore'u ana kaynak olarak kullanacaksanız)
  @override
  Future<List<DonationCenterModel>> getAllDonationCentersFromFirestore() async {
    _logger.d("Fetching all donation centers from Firestore.");
    try {
      final snapshot = await _donationCentersCollection.orderBy("name").get();
      return snapshot.docs
          .map((doc) {
            try {
              return DonationCenterModel.fromJson(
                doc.data() as Map<String, dynamic>,
              );
            } catch (e, s) {
              _logger.e(
                "Error parsing Firestore donation center. DocId: ${doc.id}, Data (first 100 chars): ${doc.data().toString().substring(0, doc.data().toString().length > 100 ? 100 : doc.data().toString().length)}",
                error: e,
                stackTrace: s,
              );
              return null;
            }
          })
          .whereType<DonationCenterModel>()
          .toList();
    } catch (e, s) {
      _logger.e(
        "Error fetching donation centers from Firestore",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // Firestore'dan yakındaki merkezleri okuma (Eğer Firestore'u ana kaynak olarak kullanacaksanız)
  @override
  Future<List<DonationCenterModel>> getNearbyDonationCentersFromFirestore({
    required GeoPoint userLocation,
    double radiusKm = 30.0,
    int limit = 20,
  }) async {
    _logger.d(
      "Getting nearby donation centers from Firestore. UserLoc: $userLocation, Radius: $radiusKm km",
    );
    try {
      final allCenters = await getAllDonationCentersFromFirestore();
      if (allCenters.isEmpty) return [];

      List<DonationCenterModel> centersWithDistance = [];
      for (var center in allCenters) {
        final distance = LocationUtils.calculateDistanceInKm(
          userLocation.latitude,
          userLocation.longitude,
          center.location.latitude,
          center.location.longitude,
        );
        if (distance <= radiusKm) {
          centersWithDistance.add(center.copyWith(distance: distance));
        }
      }

      centersWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      return centersWithDistance.take(limit).toList();
    } catch (e, s) {
      _logger.e(
        "Error getting nearby donation centers from Firestore",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
IDonationCenterRepository donationCenterRepository(Ref ref) {
  return DonationCenterRepository(ref.watch(firestoreProvider));
}

// Sadece API'den İzmir kan merkezlerini çeken provider (UI bunu kullanacak)
@Riverpod(keepAlive: true)
Future<List<DonationCenterModel>> izmirDonationCentersApi(Ref ref) async {
  final repository = ref.watch(donationCenterRepositoryProvider);
  return repository.getIzmirDonationCentersFromApi();
}

// Opsiyonel: Firestore'dan merkezleri çeken provider
@Riverpod(keepAlive: true)
Future<List<DonationCenterModel>> firestoreDonationCenters(Ref ref) async {
  final repository = ref.watch(donationCenterRepositoryProvider);
  return repository.getAllDonationCentersFromFirestore();
}
