import 'package:flutter/material.dart';
import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/data/models/user/user_profile_data_model.dart';

class StatsCard extends StatelessWidget {
  final UserProfileDataModel profileData;
  final VoidCallback? onTap;

  const StatsCard({super.key, required this.profileData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final donationCount = profileData.donationCount;
    final livesSaved =
        profileData.totalLivesSaved > 0
            ? profileData.totalLivesSaved
            : donationCount * 3; // Her bağış 3 kişiye yardımcı olduğu varsayımı

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.myDonations),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: colorScheme.primary, size: 24),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    'Bağış Geçmişiniz',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    context,
                    donationCount.toString(),
                    'Toplam Bağış',
                    Icons.bloodtype_outlined,
                  ),
                  _buildStatColumn(
                    context,
                    livesSaved.toString(),
                    'Kurtarılan Hayat',
                    Icons.people_outline,
                  ),
                  _buildStatColumn(
                    context,
                    '${profileData.points} P',
                    'Toplam Puan',
                    Icons.star_border,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap ?? () => context.push(AppRoutes.myDonations),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Detaylı Geçmiş'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.secondary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
