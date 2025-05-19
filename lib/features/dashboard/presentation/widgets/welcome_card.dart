import 'package:flutter/material.dart';
import 'package:kan_bul/data/models/user/user_model.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kan_bul/core/constants/app_sizes.dart';

/// Ana sayfa üst kısmında görünen kullanıcı bilgilerini içeren widget
/// Kullanıcı adı, avatar ve profil düzenleme erişimi içerir
class WelcomeCard extends StatelessWidget {
  final UserModel user;

  const WelcomeCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Daha modern font stillerini ayarlama
    final welcomeStyle = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant,
      letterSpacing: 0.3,
    );

    final nameStyle = GoogleFonts.montserrat(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface, // Changed from onBackground
      height: 1.2,
    );

    final buttonStyle = GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.primary,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Avatar bölümü (Hero animasyonlu)
          Hero(
            tag: 'user-avatar-${user.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    // Changed from withOpacity
                    color: colorScheme.shadow.withAlpha((0.1 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: AppSizes.avatarRadiusLarge,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child:
                    user.photoUrl == null
                        ? Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Kullanıcı bilgileri bölümü
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba,', style: welcomeStyle),
                Text(
                  user.username,
                  style: nameStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Profil düzenleme butonu
          TextButton.icon(
            onPressed: () {
              logger.t("WelcomeCard: Profil düzenle butonuna tıklandı.");
              context.push(AppRoutes.profile);
            },
            icon: Icon(
              Icons.edit_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            label: Text('Profil', style: buttonStyle),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
