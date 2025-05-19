import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// UserSettingsModel ve UserProfileDataModel importlarına artık burada doğrudan ihtiyacımız olmayabilir,
// çünkü patchleme mantığı kaldırılıyor. UserModel.fromJsonSafe bu modelleri kendi içinde halletmeli.
// import '../../data/models/user/user_settings_model.dart';
// import '../../data/models/user/user_profile_data_model.dart';
import 'package:kan_bul/core/utils/logger.dart';
// Ref importu @riverpod ile gelen specific ref tipini kullanmak için genellikle gerekmez,
// provider fonksiyonu zaten doğru Ref tipini alır.
// import 'package:riverpod/riverpod.dart';

part 'firestore_service.g.dart';

/// Firestore KULLANICI veritabanı işlemlerini yöneten servis sınıfı
class FirestoreService {
  final FirebaseFirestore _firestore;

  // Constructor'a _firestore enjekte edilebilir veya doğrudan instance kullanılabilir.
  // Provider üzerinden yönetiliyorsa, provider'dan almak daha test edilebilir yapar.
  FirestoreService(this._firestore);

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Kullanıcı bilgilerini oluşturma veya güncelleme.
  /// UserModel içindeki tüm alanların (gerekirse varsayılanlarla) dolu olduğu varsayılır.
  Future<void> setUserData(UserModel user) async {
    logger.d("FirestoreService: Setting user data for ${user.id}");
    try {
      // user.toJson() metodunun null olan iç nesneleri (settings, profileData)
      // bile boş map {} olarak serialize ettiğinden emin olun,
      // veya Firestore'un bu alanları oluşturmasını bekliyorsanız
      // ve modeliniz null kabul ediyorsa sorun olmayabilir.
      // En iyisi, UserModel oluşturulurken bu alanların her zaman
      // bir instance ile (örneğin varsayılan constructor ile) başlatılmasıdır.
      await _usersCollection
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
      logger.i(
        "FirestoreService: User data saved/merged for user ID: ${user.id}",
      );
    } catch (e, s) {
      logger.e(
        'Error setting user data for ID: ${user.id}',
        error: e,
        stackTrace: s,
      );
      throw Exception('Kullanıcı bilgileri kaydedilirken bir hata oluştu: $e');
    }
  }

  /// Kullanıcı verilerini ID'ye göre getirir.
  /// Eksik alanlar için Firestore'a geri yazma (patchleme) yapmaz.
  /// Bu sorumluluk UserModel.fromJsonSafe ve modeldeki @Default değerlerindedir.
  Future<UserModel?> getUserById(String userId) async {
    logger.d("FirestoreService: Getting user by ID: $userId");
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        logger.w("User not found in Firestore for ID: $userId");
        return null;
      }

      final rawData = doc.data();
      if (rawData == null) {
        logger.w("User data is null in Firestore for ID: $userId");
        return null;
      }

      if (rawData is! Map<String, dynamic>) {
        logger.w(
          "User data is not a Map for ID: $userId. Actual type: ${rawData.runtimeType}",
        );
        return null;
      }

      // Firestore'dan gelen veriye her zaman ID'yi ekle, çünkü belgenin içinden gelmez.
      final Map<String, dynamic> dataWithId = {...rawData, 'id': userId};

      logger.d(
        "User data successfully fetched for ID: $userId. Data keys: ${dataWithId.keys.join(', ')}",
      );

      // Model dönüşümünü UserModel.fromJsonSafe'e bırakıyoruz.
      // Bu metodun eksik alanları (modelde nullable ise null, @Default varsa varsayılan)
      // doğru şekilde işlemesi beklenir.
      try {
        final userModel = UserModel.fromJsonSafe(dataWithId);
        logger.i(
          "User model successfully created from Firestore data for ID: $userId",
        );
        return userModel;
      } catch (e, s) {
        logger.e(
          "Error converting Firestore data to UserModel for ID: $userId. Data: $dataWithId",
          error: e,
          stackTrace: s,
        );
        // Hata durumunda null döndürmek, uygulamanın çökmesini engeller
        // ama bu durumun loglanması ve izlenmesi önemlidir.
        return null;
      }
    } catch (e, s) {
      logger.e(
        "Error fetching user from Firestore for ID: $userId",
        error: e,
        stackTrace: s,
      );
      // Bu genel bir hata, belki ağ hatası vs.
      // Hata fırlatmak, çağıran katmanın bunu işlemesini sağlar.
      throw Exception("Kullanıcı verisi alınırken bir hata oluştu: $e");
    }
  }

  /// Kullanıcı dökümanındaki belirli alanları günceller.
  /// Bu metot, set + merge: true kullanarak daha güvenli bir güncelleme sağlar.
  /// `updatedAt` timestamp'i otomatik olarak eklenir.
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> dataToUpdate,
  ) async {
    logger.d(
      "FirestoreService: Updating user data for $userId with data: $dataToUpdate",
    );

    // `dataToUpdate` içinde `id` alanı varsa veya `updatedAt` manuel eklenmişse bile,
    // bizim eklediğimiz `updatedAt` öncelikli olur veya üzerine yazar.
    // Genellikle bu tür metotlar sadece güncellenecek saf veriyi alır.
    final Map<String, dynamic> dataWithTimestamp = {
      ...dataToUpdate,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _usersCollection
          .doc(userId)
          .set(dataWithTimestamp, SetOptions(merge: true));
      logger.i("User data updated successfully for ID: $userId");
    } catch (e, s) {
      logger.e(
        "Error updating user data for ID: $userId",
        error: e,
        stackTrace: s,
      );
      throw Exception('Kullanıcı bilgileri güncellenirken bir hata oluştu: $e');
    }
  }

  /// Kullanıcının konumunu ve son güncelleme zamanını günceller.
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    logger.d(
      "FirestoreService: Updating user location for $userId to $location",
    );
    try {
      // updateUserData metodunu kullanarak DRY prensibine uyalım.
      await updateUserData(userId, {
        // Firestore'da iç içe alanları güncellemek için dot notation kullanılır.
        // UserModel'inizin toJson() ve fromJson() metotlarının
        // 'profileData.location' gibi yolları doğru işlemesi gerekir.
        // Eğer profileData bir Map ise bu çalışır. Eğer bir class ise,
        // önce profileData'yı okuyup, location'ı güncelleyip, sonra tüm
        // profileData nesnesini geri yazmanız gerekebilir.
        // Mevcut AuthRepository'nizdeki patchleme mantığına bakılırsa,
        // profileData'nın Map olarak ele alındığı varsayılabilir.
        // En güvenlisi, UserModel'i alıp, profileData'sını güncelleyip,
        // sonra tüm UserModel'i setUserData ile (merge:true) kaydetmektir,
        // ama sadece konumu güncellemek için bu biraz fazla olabilir.
        // Şimdilik dot notation ile deneyelim.
        'profileData.location': location,
        'profileData.lastLocationUpdate': FieldValue.serverTimestamp(),
      });
      logger.i("User location updated successfully for UserID: $userId");
    } catch (e, s) {
      logger.e(
        "Error updating user location for UserID: $userId",
        error: e,
        stackTrace: s,
      );
      throw Exception('Kullanıcı konumu güncellenirken bir hata oluştu: $e');
    }
  }
}

/// FirestoreService için Riverpod Provider'ı.
/// Bu provider, Firestore instance'ını alarak FirestoreService'i oluşturur.
@Riverpod(
  keepAlive: true,
) // Servislerin genellikle uygulama boyunca yaşaması istenir.
FirestoreService firestoreService(Ref ref) {
  // Bağımlılık olarak FirebaseFirestore provider'ını izle
  final firestoreInstance = ref.watch(firestoreProvider);
  return FirestoreService(firestoreInstance);
}

/// FirebaseFirestore instance'ı için temel Riverpod Provider'ı.
/// Bu, testlerde mock Firestore instance'ı sağlamayı kolaylaştırır.
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}
