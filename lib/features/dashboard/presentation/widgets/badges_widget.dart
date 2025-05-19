import 'package:flutter/material.dart';
import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/data/models/user/user_profile_data_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BadgesWidget extends StatelessWidget {
  final UserProfileDataModel profileData;
  final VoidCallback? onTap;

  const BadgesWidget({super.key, required this.profileData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final level = profileData.level;
    final currentPoints = profileData.points;
    final nextLevelPoints = profileData.pointsForNextLevel;
    final progress = currentPoints / nextLevelPoints;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    'Seviyeniz ve Rozetleriniz',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // Seviye göstergesi
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: _getLevelColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      level.toString(),
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLevelTitle(),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getLevelColor(context),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        LinearPercentIndicator(
                          lineHeight: 10.0,
                          percent: progress.clamp(0.0, 1.0),
                          backgroundColor: colorScheme.secondaryContainer,
                          progressColor: _getLevelColor(context),
                          barRadius: const Radius.circular(
                            AppSizes.borderRadiusSmall,
                          ),
                          animation: true,
                          animationDuration: 1000,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          '$currentPoints / $nextLevelPoints puan',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Rozetler
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kazanılan Rozetler',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    height: 80,
                    child:
                        profileData.badges.isNotEmpty
                            ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: profileData.badges.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(
                                    width: AppSizes.paddingSmall,
                                  ),
                              itemBuilder: (context, index) {
                                return _buildBadge(
                                  context,
                                  profileData.badges[index],
                                  _getBadgeIcon(profileData.badges[index]),
                                  _getBadgeColor(
                                    profileData.badges[index],
                                    context,
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Text(
                                'Henüz rozet kazanılmadı',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                  ),
                ],
              ),

              if (profileData.badges.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingMedium),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: const Text('Tüm Rozetler'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String badgeId,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final name = _getBadgeName(badgeId);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: textTheme.bodySmall?.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getLevelColor(BuildContext context) {
    final level = profileData.level;

    if (level >= 10) return Colors.deepPurple;
    if (level >= 7) return Colors.indigo;
    if (level >= 5) return Colors.blue;
    if (level >= 3) return Colors.amber;
    return Theme.of(context).colorScheme.secondary;
  }

  String _getLevelTitle() {
    final level = profileData.level;

    if (level >= 10) return 'Hayat Kurtarıcı Uzman';
    if (level >= 7) return 'Deneyimli Kurtarıcı';
    if (level >= 5) return 'Düzenli Bağışçı';
    if (level >= 3) return 'Aktif Bağışçı';
    if (level >= 1) return 'Başlangıç Bağışçı';
    return 'Yeni Üye';
  }

  IconData _getBadgeIcon(String badgeId) {
    switch (badgeId) {
      case 'first_donation':
        return Icons.favorite;
      case 'three_donations':
        return Icons.favorite_border;
      case 'five_donations':
        return Icons.medical_services;
      case 'ten_donations':
        return Icons.volunteer_activism;
      case 'consistent_donor':
        return Icons.calendar_today;
      case 'emergency_response':
        return Icons.local_hospital;
      case 'location_hero':
        return Icons.place;
      default:
        return Icons.star;
    }
  }

  Color _getBadgeColor(String badgeId, BuildContext context) {
    switch (badgeId) {
      case 'first_donation':
        return Theme.of(context).colorScheme.primary;
      case 'three_donations':
        return Colors.orange;
      case 'five_donations':
        return Colors.green;
      case 'ten_donations':
        return Colors.indigo;
      case 'consistent_donor':
        return Colors.teal;
      case 'emergency_response':
        return Theme.of(context).colorScheme.error;
      case 'location_hero':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getBadgeName(String badgeId) {
    switch (badgeId) {
      case 'first_donation':
        return 'İlk Bağış';
      case 'three_donations':
        return '3 Bağış';
      case 'five_donations':
        return '5 Bağış';
      case 'ten_donations':
        return '10 Bağış';
      case 'consistent_donor':
        return 'Düzenli';
      case 'emergency_response':
        return 'Acil Yardım';
      case 'location_hero':
        return 'Konum Kahramanı';
      default:
        return 'Rozet';
    }
  }
}
