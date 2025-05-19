import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/core/providers/dashboard_providers.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/active_requests_list_widget.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/eligibility_card.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/nearby_requests_list_widget.dart';
import 'package:kan_bul/features/dashboard/presentation/widgets/welcome_card.dart';
import 'package:kan_bul/routes/app_routes.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece auth state'den user al
    final userProfile = ref.watch(
      authStateNotifierProvider.select((state) => state.user),
    );

    // Yükleme/Hata/Geçersiz Rol durumları
    if (userProfile == null) {
      // Auth hala yüklüyor olabilir veya hata vermiş olabilir
      return const Center(child: CircularProgressIndicator());
    }
    if (userProfile.role != UserRole.individual) {
      return const Center(
        child: Text("Bu ekran sadece bireysel kullanıcılar içindir."),
      );
    }

    // Ana içerik
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh provider'ını çağır
          await ref.read(dashboardRefreshProvider.notifier).refresh();
        },
        child: _buildDashboardContent(
          context,
          ref,
          userProfile,
        ), // ref'i gönder
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    UserModel userProfile,
  ) {
    // Seçili segment state'ini provider'dan oku
    final selectedSegmentIndex = ref.watch(selectedDashboardSegmentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. WelcomeCard (Parametre olarak user alır)
          WelcomeCard(user: userProfile),
          const SizedBox(height: AppSizes.paddingMedium),

          // 2. EligibilityCard (Parametre olarak user alır, kendi hesaplamasını yapar)
          EligibilityCard(
            userData: userProfile,
            onDonateTap: () => context.push(AppRoutes.donationCenters),
            onAppointmentTap: () => context.push(AppRoutes.myDonations),
            // Talep oluştur butonu artık burada DEĞİL
          ),
          const SizedBox(height: AppSizes.paddingXLarge),

          // 3. Segment Seçici (Provider'ı günceller)
          _buildSegmentedButton(context, ref, selectedSegmentIndex),

          const SizedBox(height: AppSizes.paddingSmall),

          // 4. Seçime Göre Liste Widget'ı (Kendi provider'ını dinler)
          Expanded(
            child: AnimatedSwitcher(
              // Geçiş efekti
              duration: const Duration(milliseconds: 300),
              child:
                  selectedSegmentIndex == 0
                      ? const NearbyRequestsListWidget(key: ValueKey('nearby'))
                      : const ActiveRequestsListWidget(key: ValueKey('active')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton(
    BuildContext context,
    WidgetRef ref,
    int currentSelection,
  ) {
    return Center(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(
              value: 0,
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_outlined, size: AppSizes.iconSizeSmall),
                  const SizedBox(width: 4),
                  const Text(
                    'Yakındaki',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
            ),
            ButtonSegment<int>(
              value: 1,
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_outlined, size: AppSizes.iconSizeSmall),
                  const SizedBox(width: 4),
                  const Flexible(
                    child: Text(
                      'Aktif Taleplerim',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          selected: {currentSelection},
          onSelectionChanged: (Set<int> newSelection) {
            // setState yerine provider'ı güncelle
            ref
                .read(selectedDashboardSegmentProvider.notifier)
                .selectSegment(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(
                  0xFFFFE7E7,
                ); // M3 önerisine uygun açık kırmızı
              }
              return const Color(0xFFF4F4F4); // M3 önerisine uygun açık gri
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFD62828); // Seçili durumda D62828 kırmızı
              }
              return Colors.black87; // Seçili olmayan durumda koyu gri
            }),
            minimumSize: WidgetStateProperty.all(const Size(0, 48)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            visualDensity: VisualDensity.comfortable,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: WidgetStateProperty.all(BorderSide.none),
            elevation: WidgetStateProperty.all(0),
            alignment: Alignment.center,
          ),
          showSelectedIcon: false,
        ),
      ),
    );
  }
}
