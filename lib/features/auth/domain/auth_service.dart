import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;

/// Kimlik doğrulama işlemleri için soyut arayüz (interface).
abstract class AuthService {
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  User? get currentAuthUser;
  Future<void> reloadCurrentUser();

  // <<< İMZA GÜNCELLENDİ >>>
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username, // Yeni isim
    required String phoneNumber, // Yeni
    required UserRole role,
    required String gender, // Yeni
    required DateTime birthDate, // Yeni
    // Role özel bilgiler
    String? bloodType,
    String? hospitalName,
    String? hospitalAddress,
    String? hospitalContact,
    String? medicalInfo,
    DateTime? lastDonationDate,
  });

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> forgotPassword(String email);
  Future<void> sendEmailVerification();

  /// Kullanıcının konum bilgisini günceller
  Future<void> updateUserLocation(String userId, GeoPoint location);
}
