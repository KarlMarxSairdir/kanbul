import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/features/blood_request/presentation/providers/user_requests_notifier.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/dashboard_list_helpers.dart';

class ActiveRequestsListWidget extends ConsumerWidget {
  const ActiveRequestsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcı ID'sini al
    final userId = ref.watch(
      authStateNotifierProvider.select((state) => state.user?.id),
    );

    // Kullanıcı ID'si yoksa hata göster
    if (userId == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    // Kullanıcının aktif taleplerini dinle
    final activeRequestsAsync = ref.watch(userActiveRequestsProvider(userId));

    return activeRequestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return buildEmptyListWidget(
            context,
            'Aktif talebiniz yok',
            isUserList: true,
          );
        }
        return buildListView(context, requests, null, true);
      },
      loading: () => buildLoadingList(),
      error:
          (e, s) => buildErrorWidget(
            context,
            ref,
            'Talepleriniz yüklenemedi',
            () => ref.invalidate(userActiveRequestsProvider(userId)),
          ),
    );
  }
}
