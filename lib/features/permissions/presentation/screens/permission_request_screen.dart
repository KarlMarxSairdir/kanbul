import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/providers/permission_provider.dart';
import 'package:kan_bul/features/permissions/presentation/screens/permission_request_screen_controller.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestScreen extends ConsumerWidget {
  const PermissionRequestScreen({super.key});

  void _navigateToDashboard(BuildContext context, UserRole role) {
    logger.i(
      "PermissionRequestScreen: Navigating to dashboard for role: $role",
    );
    switch (role) {
      case UserRole.individual:
        context.go(AppRoutes.dashboard);
        break;
      case UserRole.hospitalStaff:
        context.go(AppRoutes.hospitalDashboard);
        break;
      default:
        logger.w(
          "PermissionRequestScreen: Unknown user role: $role. Navigating to login.",
        );
        context.go(AppRoutes.login);
        break;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Konum İzni Gerekli'),
            content: const Text(
              'Kan Bul uygulaması, size yakın kan ihtiyaçlarını göstermek için konum izninize ihtiyaç duyar. '
              'Lütfen ayarlardan konum iznini etkinleştirin.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Ayarları Aç'),
                onPressed: () {
                  logger.i("PermissionRequestScreen: Opening app settings...");
                  openAppSettings();
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(permissionRequestScreenControllerProvider);
    final controller = ref.read(
      permissionRequestScreenControllerProvider.notifier,
    );

    ref.listen<
      PermissionRequestScreenData
    >(permissionRequestScreenControllerProvider, (previous, next) {
      // Handle error message
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentContext = context; // Capture context
          if (ModalRoute.of(currentContext)?.isActive ?? false) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                duration: const Duration(seconds: 3),
              ),
            );
            ref
                .read(permissionRequestScreenControllerProvider.notifier)
                .consumeSideEffects();
          }
        });
      }

      // Handle settings dialog
      if (previous?.shouldShowSettingsDialog != next.shouldShowSettingsDialog &&
          next.shouldShowSettingsDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentContext = context; // Capture context
          if (ModalRoute.of(currentContext)?.isActive ?? false) {
            _showSettingsDialog(currentContext);
            ref
                .read(permissionRequestScreenControllerProvider.notifier)
                .consumeSideEffects();
          }
        });
      }

      // Handle navigation
      if (previous?.shouldNavigateToDashboard !=
              next.shouldNavigateToDashboard &&
          next.shouldNavigateToDashboard &&
          next.userRoleForNavigation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentContext = context; // Capture context
          if (ModalRoute.of(currentContext)?.isActive ?? false) {
            _navigateToDashboard(currentContext, next.userRoleForNavigation!);
            ref
                .read(permissionRequestScreenControllerProvider.notifier)
                .consumeSideEffects();
          } else {
            logger.w(
              "PermissionRequestScreen: Context no longer active, skipping navigation.",
            );
            // Still consume the side effect to reset the state
            ref
                .read(permissionRequestScreenControllerProvider.notifier)
                .consumeSideEffects();
          }
        });
      }
    });

    if (screenData.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('İzinler kontrol ediliyor...'),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          logger.w(
            "PermissionRequestScreen: User tried to pop but PopScope prevented it.",
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.location_on_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Konum İzni Gerekli',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kan Bul uygulaması, size yakın kan ihtiyaçlarını göstermek ve kan bağışçılarını bulmak için konumunuza ihtiyaç duyar.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildPermissionStatusIndicator(
                  context,
                  screenData.locationStatus,
                ),
                const SizedBox(height: 24),
                _buildPermissionBenefits(context),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: controller.requestPermission,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Konum İznini Etkinleştir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: controller.declinePermissionsTemporarily,
                  child: const Text('Daha Sonra'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionStatusIndicator(
    BuildContext context,
    LocationPermissionStatus status,
  ) {
    final ThemeData theme = Theme.of(context);
    final Color statusColor = _getStatusColor(status);
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(status), color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStatusText(status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: onSurfaceColor.withAlpha((255 * 0.6).round()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBenefits(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.location_searching),
            title: Text('Yakınınızdaki Kan İhtiyaçlarını Görün'),
            subtitle: Text(
              'Konumunuza göre en yakın kan ihtiyaçlarını gösteriyoruz',
            ),
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Haritada Kan Bağışı Noktaları'),
            subtitle: Text('Çevrenizdeki hastane ve kan merkezlerini bulun'),
          ),
          ListTile(
            leading: Icon(Icons.notification_important),
            title: Text('Acil Kan İhtiyaçlarından Haberdar Olun'),
            subtitle: Text(
              'Yakınınızda acil kan ihtiyacı olduğunda bildirim alın',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.granted:
      case LocationPermissionStatus.limited:
        return Colors.green;
      case LocationPermissionStatus.denied:
        return Colors.orange;
      case LocationPermissionStatus.permanentlyDenied:
      case LocationPermissionStatus.restricted:
      case LocationPermissionStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.granted:
      case LocationPermissionStatus.limited:
        return Icons.check_circle;
      case LocationPermissionStatus.denied:
        return Icons.warning;
      case LocationPermissionStatus.permanentlyDenied:
      case LocationPermissionStatus.restricted:
      case LocationPermissionStatus.error:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.granted:
        return 'Konum izni verildi';
      case LocationPermissionStatus.limited:
        return 'Kısıtlı konum izni verildi';
      case LocationPermissionStatus.denied:
        return 'Konum izni reddedildi';
      case LocationPermissionStatus.permanentlyDenied:
        return 'Konum izni kalıcı olarak reddedildi';
      case LocationPermissionStatus.restricted:
        return 'Konum izni kısıtlandı';
      case LocationPermissionStatus.error:
        return 'Konum izni kontrolünde hata';
      default:
        return 'Konum izni durumu bilinmiyor';
    }
  }
}
