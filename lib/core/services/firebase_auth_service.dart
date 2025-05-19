import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart'; // Import Riverpod for Ref
import 'package:logger/logger.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/features/auth/domain/auth_service.dart'; // Import the interface
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/data/models/user/user_model.dart';

part 'firebase_auth_service.g.dart'; // Kod üretimi için part direktifi

/// Firebase kimlik doğrulama servisinin implementasyonu.
/// AuthService arayüzünü implemente eder.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = logger;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentAuthUser => _auth.currentUser;

  @override
  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload();
        _logger.d("FirebaseAuthService: Kullanıcı yeniden yüklendi.");
      } catch (e, s) {
        _logger.w(
          "FirebaseAuthService: Kullanıcı yeniden yüklenirken hata",
          error: e,
          stackTrace: s,
        );
      }
    } else {
      _logger.w(
        "FirebaseAuthService: reloadCurrentUser çağrıldı ancak kullanıcı null.",
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() {
    // This method is implemented in the repository layer
    throw UnimplementedError('This method is delegated to AuthRepository');
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required UserRole role,
    required String gender,
    required DateTime birthDate,
    String? bloodType,
    String? hospitalName,
    String? hospitalAddress,
    String? hospitalContact,
    String? medicalInfo,
    DateTime? lastDonationDate,
  }) {
    // This method is implemented in the repository layer
    throw UnimplementedError('This method is delegated to AuthRepository');
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // This method is implemented in the repository layer
    throw UnimplementedError('This method is delegated to AuthRepository');
  }

  @override
  Future<UserModel> signInWithGoogle() {
    // This method is implemented in the repository layer
    throw UnimplementedError('This method is delegated to AuthRepository');
  }

  @override
  Future<void> signOut() async {
    _logger.d("FirebaseAuthService: signOut çağrılıyor...");
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      _logger.d("FirebaseAuthService: Oturum kapatıldı.");
    } catch (e, s) {
      _logger.e(
        'FirebaseAuthService: Oturum kapatma hatası',
        error: e,
        stackTrace: s,
      );
      throw Exception('Oturum kapatma sırasında Auth hatası: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    _logger.d("FirebaseAuthService: forgotPassword çağrılıyor...");
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.d("FirebaseAuthService: Şifre sıfırlama e-postası gönderildi.");
    } on FirebaseAuthException catch (e) {
      _logger.w("FirebaseAuthService - Password Reset Auth Hatası: ${e.code}");
      throw _remapAuthException(e);
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService - Password Reset Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception('Şifre sıfırlama sırasında Auth hatası: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    _logger.d("FirebaseAuthService: sendEmailVerification çağrılıyor...");
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Doğrulama için kullanıcı oturumu açık olmalı.");
    }
    await user.reload();
    if (user.emailVerified) {
      _logger.i("E-posta zaten doğrulanmış.");
      return;
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _logger.w(
        "FirebaseAuthService - Email Verification Auth Hatası: ${e.code}",
      );
      throw _remapAuthException(e);
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService - Email Verification Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception("Doğrulama e-postası gönderilirken Auth hatası: $e");
    }
  }

  @override
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    try {
      await _usersCollection.doc(userId).update({
        'location': location,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });
      _logger.d("FirebaseAuthService: Kullanıcı konumu güncellendi: $userId");
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService: Konum güncelleme hatası",
        error: e,
        stackTrace: s,
      );
      throw Exception("Kullanıcı konumu güncellenirken hata: $e");
    }
  }

  // Firebase credential registration helper
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    _logger.d(
      "FirebaseAuthService: createUserWithEmailAndPassword çağrılıyor...",
    );
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        await userCredential.user?.updateDisplayName(username);
      } catch (_) {}
      _logger.d(
        "FirebaseAuthService: Auth kullanıcısı oluşturuldu: ${userCredential.user?.uid}",
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.w("FirebaseAuthService - Register Auth Hatası: ${e.code}");
      throw _remapAuthException(e);
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService - Register Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception("Auth kullanıcısı oluşturulurken hata: $e");
    }
  }

  // Firebase credential login helper
  Future<UserCredential> signInWithEmailCredential({
    required String email,
    required String password,
  }) async {
    _logger.d("FirebaseAuthService: signInWithEmailAndPassword çağrılıyor...");
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.d(
        "FirebaseAuthService: Auth girişi başarılı: ${userCredential.user?.uid}",
      );
      if (userCredential.user != null) {
        _usersCollection
            .doc(userCredential.user!.uid)
            .set({
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true))
            .catchError(
              (e, s) => _logger.w(
                "updatedAt güncellerken hata",
                error: e,
                stackTrace: s,
              ),
            );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.w("FirebaseAuthService - SignIn Auth Hatası: ${e.code}");
      throw _remapAuthException(e);
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService - SignIn Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception("Giriş sırasında Auth hatası: $e");
    }
  }

  // Google signin helper
  Future<UserCredential> signInWithGoogleCredential() async {
    _logger.d("FirebaseAuthService: signInWithGoogleCredential çağrılıyor...");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google hesap seçilmedi.');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      _logger.d(
        "FirebaseAuthService: Google ile Auth girişi başarılı: ${userCredential.user?.uid}",
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.w("FirebaseAuthService - Google SignIn Auth Hatası: ${e.code}");
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        _logger.w(
          "Google oturumu kapatılırken hata oluştu (Auth hatası sonrası):",
          error: signOutError,
        );
      }
      throw _remapAuthException(e);
    } catch (e, s) {
      _logger.e(
        "FirebaseAuthService - Google SignIn Genel Hata",
        error: e,
        stackTrace: s,
      );
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        _logger.w(
          "Google oturumu kapatılırken hata oluştu (Genel hata sonrası):",
          error: signOutError,
        );
      }
      throw Exception('Google ile giriş sırasında Auth hatası: $e');
    }
  }

  Exception _remapAuthException(FirebaseAuthException e) {
    String message = "Bilinmeyen bir kimlik doğrulama hatası oluştu.";
    _logger.d("Remapping FirebaseAuthException with code: ${e.code}");

    switch (e.code) {
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'user-not-found':
      case 'wrong-password':
        message = "E-posta veya şifre hatalı.";
        break;
      case 'email-already-in-use':
        message = 'Bu e-posta adresi zaten kullanımda.';
        break;
      case 'invalid-email':
        message = 'Geçersiz e-posta adresi formatı.';
        break;
      case 'weak-password':
        message = 'Şifre çok zayıf.';
        break;
      case 'requires-recent-login':
        message =
            'Bu işlem güvenlik nedeniyle yakın zamanda yeniden giriş yapmanızı gerektirir.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'Bu e-posta ile farklı bir yöntemle (örn: Google) zaten bir hesap mevcut.';
        break;
      case 'operation-not-allowed':
        message = 'Bu giriş/kayıt yöntemi şu anda aktif değil.';
        break;
      case 'network-request-failed':
        message = "Ağ bağlantısı hatası. İnternetinizi kontrol edin.";
        break;
      case 'user-disabled':
        message = "Bu kullanıcı hesabı devre dışı bırakılmış.";
        break;
      case 'too-many-requests':
        message =
            "Çok fazla hatalı deneme yaptınız. Lütfen bir süre sonra tekrar deneyin.";
        break;
      default:
        _logger.w(
          "FirebaseAuthService: Eşleşmeyen FirebaseAuthException kodu: ${e.code}. Orijinal Mesaj: ${e.message}",
        );
        message = e.message ?? message;
        break;
    }

    return Exception(message);
  }
}

// Kodla üretilmiş FirebaseAuthService provider'ı
@riverpod
FirebaseAuthService firebaseAuthService(Ref ref) {
  return FirebaseAuthService();
}
