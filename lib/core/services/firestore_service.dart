// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/user/user_model.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


part 'firestore_service.g.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// KULLANICI BİLGİLERİNİ OLUŞTURMA VEYA GÜNCELLEME.
  /// ARTIK BİR USERID VE BİR MAP<STRING, DYNAMIC> ALIYOR.
  Future<void> setUserData(String userId, Map<String, dynamic> data) async {
    logger.d("FirestoreService: Setting user data for $userId");
    try {
      await _usersCollection.doc(userId).set(data, SetOptions(merge: true));
      logger.i("FirestoreService: User data saved/merged for user ID: $userId");
    } catch (e, s) {
      logger.e(
        'Error setting user data for ID: $userId',
        error: e,
        stackTrace: s,
      );
      throw Exception('Kullanıcı bilgileri kaydedilirken bir hata oluştu: $e');
    }
  }

  /// KULLANICI VERİLERİNİ ID'YE GÖRE GETİRİR.
  /// BU METOD DOĞRU GÖRÜNÜYOR, DEĞİŞTİRMEYE GEREK YOK.
  Future<UserModel?> getUserById(String userId) async {
    logger.d("FirestoreService: Getting user by ID: $userId");
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        logger.w("User not found in Firestore for ID: $userId");
        return null;
      }
      final rawData = doc.data() as Map<String, dynamic>?;
      if (rawData == null) {
        logger.w("User data is null in Firestore for ID: $userId");
        return null;
      }
      return UserModel.fromJson({...rawData, 'id': doc.id});
    } catch (e, s) {
      logger.e(
        "Error fetching user from Firestore for ID: $userId",
        error: e,
        stackTrace: s,
      );
      throw Exception("Kullanıcı verisi alınırken bir hata oluştu: $e");
    }
  }

  /// KULLANICI DÖKÜMANINDAKİ BELİRLİ ALANLARI GÜNCELLER.
  /// BU METOD DOĞRU GÖRÜNÜYOR, DEĞİŞTİRMEYE GEREK YOK.
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> dataToUpdate,
  ) async {
    logger.d(
      "FirestoreService: Updating user data for $userId with data: $dataToUpdate",
    );
    final Map<String, dynamic> dataWithTimestamp = {
      ...dataToUpdate,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      await _usersCollection.doc(userId).update(dataWithTimestamp);
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
      // updateUserData metodunu kullanarak kodu tekrar etmeyelim.
      // İç içe geçmiş bir Map alanı olan profileData'yı güncellemek için
      // dot notation (nokta notasyonu) kullanıyoruz.
      await updateUserData(userId, {
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

// BU KISIM AYNI KALIYOR
@Riverpod(keepAlive: true)
FirestoreService firestoreService(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  return FirestoreService(firestoreInstance);
}

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}