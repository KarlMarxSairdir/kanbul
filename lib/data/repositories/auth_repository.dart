import 'package:firebase_auth/firebase_auth.dart'
    show User, FirebaseAuthException; // FirebaseAuthException da dahil edildi
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/core/enums/user_gender.dart'; // UserGender enum ve extension'ları için
// Gerekli model importları eklendi
import 'package:kan_bul/data/models/user/user_profile_data_model.dart';
import 'package:kan_bul/data/models/user/user_settings_model.dart';
// AuthService yerine birincil olarak IAuthRepository'yi import et
import 'package:kan_bul/features/auth/domain/i_auth_repository.dart';
// Alt katman servisleri
import 'package:kan_bul/core/services/firebase_auth_service.dart';
import 'package:kan_bul/core/services/firestore_service.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:cloud_firestore/cloud_firestore.dart'
    show GeoPoint, Timestamp, FieldValue; // Firestore sınıfları
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Riverpod import
import 'package:riverpod/riverpod.dart'; // Import Riverpod for Ref

part 'auth_repository.g.dart'; // Kod üretimi için part direktifi

/// AuthRepository artık AuthService değil, IAuthRepository interface'ini implemente ediyor
class AuthRepository implements IAuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final FirestoreService _firestoreService;
  final _logger = logger;

  // Constructor ile bağımlılıkları al (Dependency Injection)
  AuthRepository(this._firebaseAuthService, this._firestoreService);

  @override
  Stream<User?> get authStateChanges => _firebaseAuthService.authStateChanges;

  // --- Interface Implementasyonları ---

  @override
  User? get currentAuthUser => _firebaseAuthService.currentAuthUser;

  @override
  Future<void> reloadCurrentUser() async {
    _logger.d(
      "AuthRepository: reloadCurrentUser çağrıldı, FirebaseAuthService'e yönlendiriliyor.",
    );
    await _firebaseAuthService.reloadCurrentUser();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    _logger.d("AuthRepository: getCurrentUser çağrıldı.");
    final firebaseUser = _firebaseAuthService.currentAuthUser;
    if (firebaseUser == null) {
      _logger.d(
        "AuthRepository: Firebase kullanıcısı null, UserModel null döndürülüyor.",
      );
      return null;
    }
    try {
      _logger.d(
        "AuthRepository: Firestore'dan kullanıcı modeli getiriliyor: ${firebaseUser.uid}",
      );
      final userModel = await _firestoreService.getUserById(firebaseUser.uid);
      if (userModel == null) {
        _logger.w(
          "AuthRepository: Firestore'da kullanıcı bulunamadı: ${firebaseUser.uid}",
        );
        return null;
      }
      _logger.d(
        "AuthRepository: UserModel başarıyla getirildi: ${userModel.id}",
      );
      return userModel;
    } catch (e, s) {
      _logger.e(
        "AuthRepository: getCurrentUser Firestore hatası",
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  @override
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
    String? associatedDonationCenterId, // YENİ PARAMETRE EKLENDİ
  }) async {
    _logger.d(
      "AuthRepository: registerWithEmailAndPassword çağrıldı. Role: $role, CenterID: $associatedDonationCenterId",
    );
    try {
      // 1. Firebase Auth kullanıcısını oluştur
      final userCredential = await _firebaseAuthService
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
            username: username, // Pass username to FirebaseAuthService
          );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Firebase Auth kullanıcısı oluşturulamadı.");
      }
      _logger.d(
        "AuthRepository: Firebase Auth kullanıcısı oluşturuldu: ${firebaseUser.uid}",
      );

      // Cinsiyet değerini doğru şekilde dönüştür (sadece bireysel kullanıcılar için anlamlı)
      UserGender userGender = UserGender.unknown;
      if (role != UserRole.hospitalStaff && gender != null) {
        userGender = UserGender.values.firstWhere(
          (e) =>
              e.name.toLowerCase() == gender.toLowerCase() ||
              e.displayText.toLowerCase() == gender.toLowerCase(),
          orElse: () => UserGender.unknown,
        );
      }

      final now = DateTime.now();
      UserProfileDataModel profileData;

      if (role == UserRole.hospitalStaff) {
        profileData = UserProfileDataModel(
          gender: UserGender.unknown, // Hastane personeli için varsayılan
          birthDate: null, // Hastane personeli için doğum tarihi gereksiz
          bloodType: null, // Hastane personeli için kan grubu gereksiz
          medicalInfo: medicalInfo, // Ortak olabilir
          hospitalName: hospitalName,
          hospitalAddress: hospitalAddress,
          hospitalContact: hospitalContact,
          associatedDonationCenterId:
              associatedDonationCenterId, // Atama yapılıyor
          // lastDonationDate null kalacak (varsayılan)
        );
      } else {
        // Bireysel veya diğer roller
        profileData = UserProfileDataModel(
          gender: userGender,
          birthDate:
              birthDate != null
                  ? Timestamp.fromDate(birthDate)
                  : null, // Nullable DateTime kontrolü
          bloodType: bloodType,
          medicalInfo: medicalInfo,
          lastDonationDate:
              lastDonationDate != null
                  ? Timestamp.fromDate(lastDonationDate)
                  : null,
          // hospitalName, hospitalAddress, hospitalContact null kalacak (varsayılan)
          // associatedDonationCenterId null kalacak (varsayılan)
        );
      }

      // 2. UserModel objesini oluştur
      final newUserModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        username: username,
        phoneNumber: phoneNumber,
        role: role,
        profileData: profileData, // GÜNCELLENMİŞ profileData KULLANILIYOR
        emailVerified: firebaseUser.emailVerified, // Initially false
        createdAt: Timestamp.fromDate(now),
        updatedAt: Timestamp.fromDate(now),
        settings: const UserSettingsModel(), // Default settings
      );
      _logger.d(
        "AuthRepository: UserModel objesi oluşturuldu: ${newUserModel.id} with profileData: ${profileData.toJson()}",
      );

      // 3. UserModel'i Firestore'a kaydet
      await _firestoreService.setUserData(newUserModel);
      _logger.d(
        "AuthRepository: UserModel Firestore'a kaydedildi: ${newUserModel.id}",
      );

      // 4. E-posta doğrulama maili gönder
      await _firebaseAuthService.sendEmailVerification();
      _logger.d(
        "AuthRepository: Doğrulama e-postası gönderildi: ${firebaseUser.email}",
      );

      // 5. Oluşturulan UserModel'i döndür
      return newUserModel;
    } on FirebaseAuthException catch (e) {
      _logger.w(
        "AuthRepository - Register Auth Hatası: ${e.code} - ${e.message}",
      );
      rethrow;
    } catch (e, s) {
      _logger.e(
        "AuthRepository - Register Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception("Kayıt sırasında beklenmedik bir hata oluştu: $e");
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _logger.d("AuthRepository: signInWithEmailAndPassword çağrıldı.");
    try {
      // 1. Firebase Auth ile giriş yap
      final userCredential = await _firebaseAuthService
          .signInWithEmailCredential(email: email, password: password);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Firebase Auth girişi başarısız oldu.");
      }
      _logger.d(
        "AuthRepository: Firebase Auth girişi başarılı: ${firebaseUser.uid}",
      );

      // 2. Firestore'dan UserModel'i getir
      final userModel = await _firestoreService.getUserById(firebaseUser.uid);
      if (userModel == null) {
        _logger.e(
          "AuthRepository: Giriş başarılı ama Firestore'da kullanıcı bulunamadı!: ${firebaseUser.uid}",
        );
        throw Exception(
          "Kullanıcı profili bulunamadı. Lütfen destek ile iletişime geçin.",
        );
      }
      _logger.d(
        "AuthRepository: UserModel başarıyla getirildi: ${userModel.id}",
      );

      // 3. Getirilen UserModel'i döndür
      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.w("AuthRepository - SignIn Auth Hatası: ${e.code}");
      rethrow;
    } catch (e, s) {
      _logger.e("AuthRepository - SignIn Genel Hata", error: e, stackTrace: s);
      throw Exception("Giriş sırasında beklenmedik bir hata oluştu: $e");
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    _logger.d("AuthRepository: signInWithGoogle çağrıldı.");
    try {
      // 1. Firebase Auth ile Google girişi yap
      final userCredential =
          await _firebaseAuthService.signInWithGoogleCredential();
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Google ile Firebase Auth girişi başarısız oldu.");
      }
      _logger.d(
        "AuthRepository: Google ile Firebase Auth girişi başarılı: ${firebaseUser.uid}",
      );
      // 2. Firestore'dan UserModel'i getir veya oluştur
      UserModel? userModel = await _firestoreService.getUserById(
        firebaseUser.uid,
      );

      if (userModel == null) {
        _logger.i(
          "AuthRepository: Google kullanıcısı Firestore'da bulunamadı, yeni profil oluşturuluyor: ${firebaseUser.uid}",
        );
        final now = DateTime.now();
        userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              'Kullanıcı',
          phoneNumber: '',
          role: UserRole.individual,
          profileData: UserProfileDataModel(
            gender: UserGender.unknown, // Doğrudan enum değeri kullanılıyor
            birthDate: Timestamp.fromDate(DateTime(1900, 1, 1)), // Doğru format
            bloodType: null,
          ),
          emailVerified: firebaseUser.emailVerified,
          createdAt: Timestamp.fromDate(now), // DateTime -> Timestamp
          updatedAt: Timestamp.fromDate(now), // DateTime -> Timestamp
          settings: UserSettingsModel(),
        );
        await _firestoreService.setUserData(userModel);
        _logger.d(
          "AuthRepository: Yeni Google kullanıcısı için UserModel Firestore'a kaydedildi.",
        );
      } else {
        _logger.d(
          "AuthRepository: Mevcut Google kullanıcısı için UserModel Firestore'dan getirildi: ${userModel.id}",
        );
        // Opsiyonel: Firestore'daki verileri Google'dan gelenlerle güncelleme
      }

      // 3. UserModel'i döndür
      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.w("AuthRepository - Google SignIn Auth Hatası: ${e.code}");
      await _firebaseAuthService.signOut().catchError((_) {});
      rethrow;
    } catch (e, s) {
      _logger.e(
        "AuthRepository - Google SignIn Genel Hata",
        error: e,
        stackTrace: s,
      );
      await _firebaseAuthService.signOut().catchError((_) {});
      throw Exception(
        "Google ile giriş sırasında beklenmedik bir hata oluştu: $e",
      );
    }
  }

  @override
  Future<void> signOut() async {
    _logger.d("AuthRepository: signOut çağrıldı.");
    await _firebaseAuthService.signOut();
    _logger.d("AuthRepository: Firebase Auth oturumu kapatıldı.");
  }

  @override
  Future<void> forgotPassword(String email) async {
    _logger.d("AuthRepository: forgotPassword çağrıldı: $email");
    try {
      await _firebaseAuthService.forgotPassword(email);
      _logger.d("AuthRepository: Şifre sıfırlama e-postası gönderildi: $email");
    } on FirebaseAuthException catch (e) {
      _logger.w("AuthRepository - PasswordReset Hatası: ${e.code}", error: e);
      rethrow;
    } catch (e, s) {
      _logger.e(
        "AuthRepository - PasswordReset Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception(
        "Şifre sıfırlama e-postası gönderilirken bir hata oluştu: $e",
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    _logger.d(
      "AuthRepository: sendEmailVerification çağrıldı, FirebaseAuthService'e yönlendiriliyor.",
    );
    try {
      await _firebaseAuthService.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _logger.w("AuthRepository - Send Verification Auth Hatası: ${e.code}");
      rethrow;
    } catch (e, s) {
      _logger.e(
        "AuthRepository - Send Verification Genel Hata",
        error: e,
        stackTrace: s,
      );
      throw Exception("E-posta doğrulama gönderilirken bir hata oluştu: $e");
    }
  }

  @override
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    _logger.d("AuthRepository: updateUserLocation çağrıldı for $userId");
    try {
      await _firestoreService.updateUserLocation(userId, location);
      _logger.d("AuthRepository: Kullanıcı konumu güncellendi: $userId");
    } catch (e, s) {
      _logger.e(
        "AuthRepository - Konum Güncelleme Hatası",
        error: e,
        stackTrace: s,
      );
      throw Exception("Konum güncellenirken bir hata oluştu: $e");
    }
  }

  // Firebase Auth'daki emailVerified durumunu Firestore'a senkronize etmek için
  Future<void> updateUserEmailVerifiedStatus(
    String userId,
    bool emailVerified,
  ) async {
    _logger.d(
      "AuthRepository: updateUserEmailVerifiedStatus çağrıldı. userId: $userId, emailVerified: $emailVerified",
    );
    try {
      // Firestore'da kullanıcının emailVerified alanını güncelle
      await _firestoreService.updateUserData(userId, {
        'emailVerified': emailVerified,
      });
      _logger.i(
        "AuthRepository: Kullanıcının emailVerified durumu Firestore'da güncellendi: $emailVerified",
      );
    } catch (e, s) {
      _logger.e(
        "AuthRepository: emailVerified güncelleme hatası",
        error: e,
        stackTrace: s,
      );
      throw Exception(
        "EmailVerified durumu güncellenirken bir hata oluştu: $e",
      );
    }
  }

  /// Firebase ve Firestore'dan güncel kullanıcı bilgilerini yükler ve senkronize eder
  /// Önce Firebase Auth kullanıcısını reload eder, sonra Firestore profilini yükler
  /// ve FirebaseAuth'tan emailVerified durumunu senkronize eder.
  @override
  Future<UserModel?> ensureCurrentUserLoaded() async {
    _logger.d("AuthRepository: ensureCurrentUserLoaded çağrıldı");
    final firebaseUser = _firebaseAuthService.currentAuthUser;

    if (firebaseUser == null) {
      _logger.w(
        "AuthRepository: ensureCurrentUserLoaded - Firebase kullanıcı yok",
      );
      return null;
    }

    try {
      // 1. Firebase kullanıcıyı reload et
      await _firebaseAuthService.reloadCurrentUser();
      final refreshedFirebaseUser = _firebaseAuthService.currentAuthUser;

      if (refreshedFirebaseUser == null) {
        _logger.w(
          "AuthRepository: reload sonrası Firebase kullanıcısı null oldu",
        );
        return null;
      }

      // 2. Firestore'dan profil bilgilerini getir
      UserModel? userModel = await _firestoreService.getUserById(
        refreshedFirebaseUser.uid,
      );

      // 3. Eğer Firestore'dan kullanıcı verisi gelmezse - yeni profil oluştur
      if (userModel == null) {
        _logger.w(
          "AuthRepository: Firestore profili bulunamadı - yeni profil oluşturulacak: ${refreshedFirebaseUser.uid}",
        );
        // Yeni bir temel UserModel oluştur
        final now = DateTime.now();
        userModel = UserModel(
          id: refreshedFirebaseUser.uid,
          email: refreshedFirebaseUser.email ?? '',
          username:
              refreshedFirebaseUser.displayName ??
              refreshedFirebaseUser.email?.split('@').first ??
              'Kullanıcı',
          phoneNumber: refreshedFirebaseUser.phoneNumber,
          role: UserRole.individual, // Varsayılan rol
          emailVerified: refreshedFirebaseUser.emailVerified,
          settings: const UserSettingsModel(), // Boş ayarlar
          profileData: const UserProfileDataModel(), // Boş profil verisi
          createdAt: Timestamp.fromDate(now),
          updatedAt: Timestamp.fromDate(now),
        );

        // Yeni oluşturulan profili Firestore'a kaydet (yeni doküman oluşturulduğu için merge gerekmez)
        await _firestoreService.setUserData(userModel);
        _logger.i(
          "AuthRepository: Firestore'da eksik profil oluşturuldu: ${userModel.id}",
        );
      }

      // 4. Email doğrulama durumunu senkronize et (sadece emailVerified değiştiğinde)
      final authEmailVerified = refreshedFirebaseUser.emailVerified;
      final firestoreEmailVerified = userModel.emailVerified;

      if (authEmailVerified != firestoreEmailVerified) {
        _logger.i(
          "AuthRepository: Email doğrulama durumu değişti (Auth: $authEmailVerified, Firestore: $firestoreEmailVerified). Firestore güncelleniyor.",
        );

        // SADECE emailVerified ve updatedAt alanlarını güncelle (merge: true ile)
        Map<String, dynamic> updates = {
          'emailVerified': authEmailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestoreService.updateUserData(
          refreshedFirebaseUser.uid,
          updates,
        );
        _logger.d(
          "AuthRepository: Firestore emailVerified durumu güncellendi.",
        );

        // userModel varsa yerel olarak güncelle
        userModel = userModel.copyWith(emailVerified: authEmailVerified);
      }

      // 5. Son güncel UserModel'i tekrar oku (varsa önceki değişikliklerden sonra)
      // Bu adım, Firestore'dan en güncel veriyi almak için önemlidir, özellikle `updatedAt` gibi sunucu taraflı güncellenen alanlar varsa.
      // Ancak, eğer `updateUserData` sadece `emailVerified` ve `updatedAt`'ı güncelliyorsa ve `userModel.copyWith` ile yerel model güncelleniyorsa,
      // bu tekrar okuma bazı durumlarda gereksiz olabilir. Performans ve veri tutarlılığı ihtiyaçlarına göre değerlendirilmelidir.
      // Şimdilik, tutarlılık için bırakıyoruz.
      userModel = await _firestoreService.getUserById(
        refreshedFirebaseUser.uid,
      );

      _logger.d(
        "AuthRepository: Kullanıcı profili yüklendi/güncellendi (${userModel?.id}), emailVerified: ${userModel?.emailVerified}",
      );
      return userModel;
    } catch (e, s) {
      _logger.e(
        "AuthRepository: ensureCurrentUserLoaded hatası",
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AuthRepository(firebaseAuthService, firestoreService);
}
