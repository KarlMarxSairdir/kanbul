import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthException için eklendi
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/data/repositories/auth_repository.dart'; // authRepositoryProvider için
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_notifier.g.dart';

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  FutureOr<void> build() {
    // Initial state is AsyncData(null) by default for AsyncNotifier<void>
    return null;
  }

  Future<UserModel> run({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(
            authRepositoryProvider,
          ) // IAuthRepository implementasyonunu okur
          .registerWithEmailAndPassword(
            email: email,
            password: password,
            username: username,
            phoneNumber: phoneNumber,
            role: role,
            gender:
                gender, // Değişiklik yok, zaten nullable kabul ediyor olmalı (veya repository'de handle ediliyor)
            birthDate: birthDate, // Değişiklik yok
            bloodType: bloodType,
            hospitalName: hospitalName,
            hospitalAddress: hospitalAddress,
            hospitalContact: hospitalContact,
            medicalInfo: medicalInfo,
            lastDonationDate: lastDonationDate,
            associatedDonationCenterId:
                associatedDonationCenterId, // <<< YENİ PARAMETRE İLETİLİYOR
          );
      state = const AsyncValue.data(
        null,
      ); // İşlem başarılı, state'i sıfırla (data void olduğu için null)
      return user; // Başarılı kullanıcı modelini döndür
    } on FirebaseAuthException catch (e, st) {
      logger.w(
        "RegisterNotifier: FirebaseAuthException during registration",
        error: e.message, // Hata mesajını logla
        // stackTrace: st, // Gerekirse stack trace de loglanabilir
      );
      state = AsyncValue.error(e, st); // Hata state'ini ayarla
      rethrow; // Hatanın UI katmanına da ulaşmasını sağla
    } catch (e, st) {
      logger.e(
        "RegisterNotifier: Generic error during registration",
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
