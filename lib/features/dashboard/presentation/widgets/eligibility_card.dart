import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/core/theme/app_theme.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:lottie/lottie.dart';

class EligibilityCard extends StatelessWidget {
  final UserModel userData;
  final VoidCallback onDonateTap;
  final VoidCallback onAppointmentTap;

  const EligibilityCard({
    super.key,
    required this.userData,
    required this.onDonateTap,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final profileData = userData.profileData;
    final bool isEligible = profileData.isEligibleToDonate;
    final DateTime? nextEligibleDate = profileData.nextEligibleDonationDate;

    String eligibilityText;
    Color statusColor;
    IconData statusIcon;

    if (isEligible) {
      eligibilityText = 'Kan Bağışı İçin Uygunsunuz';
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
    } else {
      final nextDate = nextEligibleDate;
      if (nextDate != null) {
        final daysRemaining = nextDate.difference(DateTime.now()).inDays;
        eligibilityText =
            daysRemaining > 0
                ? 'Sonraki bağış: $daysRemaining gün sonra'
                : 'Uygunluk tarihi geçmiş olabilir';
      } else {
        eligibilityText = 'Son bağış tarihi bilinmiyor';
      }
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.access_time;
    }

    return Card(
      elevation: 8,
      color: Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kan Grubu Bilgisi (önceden WelcomeCard içindeydi)
            if (profileData.bloodType != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bloodtype,
                    size: 24,
                    color: AppTheme.getBloodTypeBackgroundColor(
                      profileData.bloodType!,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getBloodTypeBackgroundColor(
                        profileData.bloodType!,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profileData.bloodType!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
            ],

            // 2. Uygunluk Durumu Bilgisi
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: AppSizes.iconSizeSmall,
                  color: statusColor,
                ),
                const SizedBox(width: AppSizes.paddingXSmall),
                Expanded(
                  child: Text(
                    eligibilityText,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      height: 1.4,
                      color: statusColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isEligible)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Lottie.asset(
                      'assets/animations/check_animation.json',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.check, color: statusColor, size: 16),
                    ),
                  ),
              ],
            ),

            // 3. Son Bağış Tarihi (Varsa)
            if (profileData.lastDonationDate != null) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                'Son Bağış: ${DateFormat('dd.MM.yyyy').format(profileData.lastDonationDate!.toDate())}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],

            // 4. Eylem Butonları
            const SizedBox(height: AppSizes.paddingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: onDonateTap,
                  icon: const Icon(Icons.place_outlined),
                  label: Text('Bağış Noktaları', style: GoogleFonts.nunito()),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
