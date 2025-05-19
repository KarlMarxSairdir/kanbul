import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;

/// Auth Repository katmanı için soyut arayüz (interface).
/// Veri işlemleri ve iş mantığını tanımlar.
abstract class IAuthRepository {
  /// Kimlik doğrulama durumu değişikliklerini dinler
  Stream<User?> get authStateChanges;

  /// Mevcut kimlik doğrulanmış kullanıcıya erişim
  User? get currentAuthUser;

  /// Mevcut kullanıcının Firestore'dan profil bilgilerini döndürür
  Future<UserModel?> getCurrentUser();

  /// Firebase Auth kullanıcısını yeniden yükler
  Future<void> reloadCurrentUser();

  /// E-posta ve şifre ile kayıt olur ve Firestore'a profil oluşturur
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required UserRole role,
    String? gender, // Değiştirildi: Nullable yapıldı
    DateTime? birthDate, // Değiştirildi: Nullable yapıldı
    String? bloodType,
    String? hospitalName,
    String? hospitalAddress,
    String? hospitalContact,
    String? medicalInfo,
    DateTime? lastDonationDate,
    String? associatedDonationCenterId, // <<< YENİ PARAMETRE EKLENDİ
  });

  /// E-posta ve şifre ile giriş yapar ve Firestore'dan profil bilgilerini getirir
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Google hesabıyla giriş yapar ve Firestore'dan profil bilgilerini getirir
  Future<UserModel> signInWithGoogle();

  /// Kullanıcı oturumunu kapatır
  Future<void> signOut();

  /// Şifre sıfırlama e-postası gönderir
  Future<void> forgotPassword(String email);

  /// E-posta doğrulama mesajı gönderir
  Future<void> sendEmailVerification();

  /// Kullanıcının konum bilgisini günceller
  Future<void> updateUserLocation(String userId, GeoPoint location);

  /// Firebase ve Firestore'dan güncel kullanıcı bilgilerini yükler ve senkronize eder
  Future<UserModel?> ensureCurrentUserLoaded();

  // updateUserEmailVerifiedStatus metodu da arayüzde tanımlı olabilir, eğer
  // repository dışından çağrılması gerekiyorsa. Şimdilik AuthRepository içinde private kalmıştı.
  // Eğer public bir metot ise buraya da eklenmeli:
  // Future<void> updateUserEmailVerifiedStatus(String userId, bool emailVerified);
}
