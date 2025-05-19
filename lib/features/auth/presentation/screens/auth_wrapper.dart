// lib/features/auth/presentation/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/providers/permission_provider.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/features/dashboard/presentation/screens/dashboard_screen.dart'; // Dashboard UI
import 'package:kan_bul/features/dashboard/presentation/screens/hospital_staff_dashboard.dart'; // Diğer Dashboard
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/features/permissions/presentation/screens/permission_request_screen.dart'; // PermissionRequestScreen importu
import 'package:kan_bul/features/auth/login_screen.dart'; // Düzeltilmiş LoginScreen importu

/// Kimlik doğrulama durumuna göre kullanıcıyı yönlendiren wrapper
class AuthWrapper extends ConsumerWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child}); // super.key kullanımı

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod ile auth state'ini dinle
    final authState = ref.watch(authStateNotifierProvider);
    final permissionAsyncValue = ref.watch(permissionCheckProvider);

    logger.d(
      "AuthWrapper Build: Auth isLoading=${authState.isLoading}, "
      "User=${authState.user?.id}, "
      "Permission isLoading=${permissionAsyncValue.isLoading}",
    );

    // Yükleniyor durumu
    if (authState.isLoading) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }

    // Oturumu açık kullanıcı yoksa login ekranına yönlendir
    if (authState.user == null) {
      logger.d("AuthWrapper: User is null. Returning LoginScreen UI.");
      return const LoginScreen();
    }

    // E-posta doğrulama gerektiren durum
    if (!authState.user!.emailVerified) {
      logger.d(
        "AuthWrapper: Email not verified. Returning EmailVerificationScreen UI.",
      );
      context.go(AppRoutes.emailVerification);
      return Container(); // Go Router tarafından bu widget gösterilmeyecek
    }

    // Oturumu açık kullanıcı varsa, child widget göster
    final user = authState.user!;

    // 4. İzinler Verilmemiş - Hem kullanıcının kabul ettiği hem de gerçek sistem izinlerini kontrol et
    final permissionsGranted = permissionAsyncValue.valueOrNull ?? false;
    if (!permissionsGranted) {
      // İzin hatası varsa onu da gösterebiliriz
      if (permissionAsyncValue.hasError) {
        logger.e(
          "AuthWrapper: Permission check error.",
          error: permissionAsyncValue.error,
          stackTrace: permissionAsyncValue.stackTrace,
        );
        return Scaffold(
          body: Center(
            child: Text("İzin kontrolünde hata: ${permissionAsyncValue.error}"),
          ),
        );
      }
      logger.d(
        "AuthWrapper: Permissions not granted. Returning PermissionRequestScreen UI.",
      );
      return const PermissionRequestScreen(); // Kendi Scaffold'u var
    }

    // 5. Her Şey Tamam -> Doğru Dashboard UI'ını Döndür
    logger.d(
      "AuthWrapper: All checks OK. Returning appropriate Dashboard UI for role: ${user.role}.",
    );
    switch (user.role) {
      case UserRole.individual:
        // DashboardScreen'in kendi Scaffold'u OLMAMALI (Shell içinde)
        return const DashboardScreen();
      case UserRole.hospitalStaff:
        // HospitalStaffDashboard'un kendi Scaffold'u OLMALI
        return const HospitalStaffDashboard();
      default:
        logger.w(
          "AuthWrapper: Unknown user role: ${user.role}. Showing fallback.",
        );
        // Fallback - Belki bir hata ekranı veya Login'e yönlendirme (redirect halleder)
        return const Scaffold(
          body: Center(child: Text("Geçersiz Kullanıcı Rolü")),
        );
    }
  }
}
