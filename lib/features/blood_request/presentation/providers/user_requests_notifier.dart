import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'user_requests_notifier.g.dart';

/// Belirli bir kullanıcının duruma göre taleplerini izleyen stream provider.
/// Bu notifier, kullanıcının tüm active/fulfilled/canceled taleplerini dinler.
@Riverpod(keepAlive: true)
Stream<List<BloodRequest>> userRequestsByStatus(
  Ref ref, {
  required String userId,
  required String status,
}) {
  ref.onDispose(() {
    // Stream dinlemesi otomatik iptal olur
  });

  // IBloodRequestRepository arayüzünü kullanarak veri al
  final repository = ref.watch(bloodRequestRepositoryProvider);
  return repository.watchUserRequestsByStatus(userId, status);
}

/// Kullanıcının aktif (status=active) taleplerini izleyen provider
@riverpod
Stream<List<BloodRequest>> userActiveRequests(Ref ref, String userId) {
  // repository üzerinden gerekli metodu çağır
  final repository = ref.watch(bloodRequestRepositoryProvider);
  return repository.watchUserRequestsByStatus(userId, 'active');
}

/// Kullanıcının tamamlanmış (status=fulfilled) taleplerini izleyen provider
@riverpod
Stream<List<BloodRequest>> userFulfilledRequests(Ref ref, String userId) {
  // repository üzerinden gerekli metodu çağır
  final repository = ref.watch(bloodRequestRepositoryProvider);
  return repository.watchUserRequestsByStatus(userId, 'fulfilled');
}

/// Kullanıcının iptal edilmiş (status=canceled) taleplerini izleyen provider
@riverpod
Stream<List<BloodRequest>> userCanceledRequests(Ref ref, String userId) {
  // repository üzerinden gerekli metodu çağır
  final repository = ref.watch(bloodRequestRepositoryProvider);
  return repository.watchUserRequestsByStatus(userId, 'canceled');
}
