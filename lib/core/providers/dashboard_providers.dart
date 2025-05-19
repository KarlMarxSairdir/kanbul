import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/features/blood_request/presentation/providers/top_nearby_notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/providers/location_provider.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dashboard_providers.g.dart';

// 0: Yakındaki, 1: Aktif Taleplerim
@riverpod
class SelectedDashboardSegment extends _$SelectedDashboardSegment {
  @override
  int build() => 0; // Başlangıçta Yakındaki seçili

  void selectSegment(int index) {
    state = index;
  }
}

@riverpod
class DashboardRefresh extends _$DashboardRefresh {
  @override
  FutureOr<void> build() {
    // Başlangıçta bir şey yapmaya gerek yok
    return null;
  }

  Future<void> refresh() async {
    // İlgili provider'ları invalidate et
    ref.invalidate(topNearbyNotifierProvider);
    ref.invalidate(currentPositionProvider); // Konumu da yenileyebiliriz
    // Kullanıcı verisini de yenile
    await ref.read(authStateNotifierProvider.notifier).refreshUser();
  }
}

/// Kullanıcı konumuna göre yakındaki kan talepleri sayısı
/// Dinamik olarak hesaplanır
@riverpod
AsyncValue<int> nearbyBloodRequestsCount(Ref ref) {
  // NearbyBloodRequestsCountRef -> Ref
  final nearbyRequests = ref.watch(topNearbyNotifierProvider);
  return nearbyRequests.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (requests) => AsyncValue.data(requests.length),
  );
}

/// Kullanıcı rolüne göre gösteri state'i
@riverpod
UserRole? userRoleDisplay(Ref ref) {
  // UserRoleDisplayRef -> Ref
  final authState = ref.watch(authStateNotifierProvider);
  if (authState.user == null) {
    return null;
  }
  return authState.user!.role;
}

/// Konum durumu
@riverpod
AsyncValue<Position?> locationState(Ref ref) {
  // LocationStateRef -> Ref
  return ref.watch(currentPositionProvider);
}
