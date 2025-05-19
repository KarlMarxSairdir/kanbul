// lib/routes/app_router.dart

import 'dart:async'; // StreamSubscription için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/features/auth/email_verification_screen.dart';
import 'package:kan_bul/features/auth/forgot_password_screen.dart';
import 'package:kan_bul/features/auth/login_screen.dart';
import 'package:kan_bul/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:kan_bul/features/auth/register_screen.dart';
import 'package:kan_bul/features/blood_request/presentation/screens/blood_request_detail_screen.dart';
import 'package:kan_bul/features/blood_request/presentation/screens/blood_requests_screen.dart';
import 'package:kan_bul/features/blood_request/presentation/screens/create_blood_request_screen.dart';
import 'package:kan_bul/features/blood_request/presentation/screens/manage_donation_offers_screen.dart';
import 'package:kan_bul/features/blood_request/presentation/screens/respond_to_request_screen.dart';
import 'package:kan_bul/features/chat/presentation/screens/chat_screen.dart';
import 'package:kan_bul/features/chat/presentation/screens/my_chats_screen.dart';
import 'package:kan_bul/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kan_bul/features/dashboard/presentation/screens/hospital_staff_dashboard.dart';
import 'package:kan_bul/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:kan_bul/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:kan_bul/features/permissions/presentation/screens/permission_request_screen.dart';
import 'package:kan_bul/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:kan_bul/features/profile/presentation/screens/profile_screen.dart';
import 'package:kan_bul/features/settings/presentation/screens/settings_screen.dart';
import 'package:kan_bul/features/splash/presentation/screens/splash_screen.dart';
import 'package:kan_bul/features/map/presentation/screens/all_requests_map_screen.dart';
import 'package:kan_bul/presentation/screens/admin/donation_centers_screen.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/widgets/scaffold_with_navbar.dart';
import 'package:kan_bul/features/map/presentation/screens/map_screen.dart';

// Navigator key'ler tanımlanıyor
class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKeyDashboard = GlobalKey<NavigatorState>(
    debugLabel: 'shellDashboard',
  );
  static final shellNavigatorKeyManageDonationOffers =
      GlobalKey<NavigatorState>(debugLabel: 'shellManageDonationOffers');
  static final shellNavigatorKeyActiveRequestsMap = GlobalKey<NavigatorState>(
    debugLabel: 'shellActiveRequestsMap',
  );
  static final shellNavigatorKeyBloodRequests = GlobalKey<NavigatorState>(
    debugLabel: 'shellBloodRequests',
  );
  static final shellNavigatorKeyChat = GlobalKey<NavigatorState>(
    debugLabel: 'shellChat',
  );

  // --- Rota Listesi (statik) ---
  static final List<RouteBase> routes = [
    // Başlangıç ve Kimlik Doğrulama Rotaları
    GoRoute(
      path: AppRoutes.splash,
      builder: (c, s) => const SplashScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (c, s) => const OnboardingScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (c, s) => const LoginScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (c, s) => const ForgotPasswordScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (c, s) => const RegisterScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.emailVerification,
      builder: (c, s) => const EmailVerificationScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.permissionRequest,
      builder: (c, s) => const PermissionRequestScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.authWrapper,
      builder: (c, s) => const AuthWrapper(child: SplashScreen()),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.hospitalDashboard,
      name: AppRoutes.hospitalDashboard,
      builder: (c, s) => const HospitalStaffDashboard(),
      parentNavigatorKey: rootNavigatorKey,
    ),

    // Ana navigasyon kabuğu - StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Branch 0: Dashboard
        StatefulShellBranch(
          navigatorKey: shellNavigatorKeyDashboard,
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.dashboard,
              name: AppRoutes.dashboard,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: DashboardScreen()),
            ),
          ],
        ), // Branch 1: Harita + Liste
        StatefulShellBranch(
          navigatorKey: shellNavigatorKeyActiveRequestsMap,
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.manageDonationOffers,
              name: AppRoutes.manageDonationOffers,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: AllRequestsMapScreen()),
            ),
          ],
        ),

        // Branch 2: Kan Talepleri- Hepsi
        StatefulShellBranch(
          navigatorKey: shellNavigatorKeyBloodRequests,
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.bloodRequests,
              name: AppRoutes.bloodRequests,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: BloodRequestsScreen()),
            ),
          ],
        ),

        // Branch 3: Chat Screen (Updated)
        StatefulShellBranch(
          navigatorKey: shellNavigatorKeyChat,
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.myChats,
              name: AppRoutes.myChats,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: MyChatsScreen()),
            ),
          ],
        ),
      ],
    ),

    // Shell DIŞINDA kalan rotalar
    GoRoute(
      path: AppRoutes.notifications,
      name: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: '${AppRoutes.bloodRequestDetail}/:requestId',
      name: AppRoutes.bloodRequestDetail,
      builder: (context, state) {
        final requestId = state.pathParameters['requestId'];
        if (requestId == null || requestId.isEmpty) {
          logger.e("BloodRequestDetail rotası için ID eksik!");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.dashboard);
          });
          return const Scaffold(body: Center(child: Text("Geçersiz Talep ID")));
        }
        return BloodRequestDetailScreen(requestId: requestId);
      },
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.createBloodRequest,
      name: AppRoutes.createBloodRequest,
      builder: (context, state) => const CreateBloodRequestScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: '${AppRoutes.respondToRequest}/:requestId',
      name: AppRoutes.respondToRequest,
      builder: (context, state) {
        final requestId = state.pathParameters['requestId'];
        if (requestId == null || requestId.isEmpty) {
          logger.e("RespondToRequest rotası için ID eksik!");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.dashboard);
          });
          return const Scaffold(body: Center(child: Text("Geçersiz Talep ID")));
        }
        return RespondToRequestScreen(requestId: requestId);
      },
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: '/manage-donation-offers/:requestId',
      name: AppRoutes.manageDonationOffersDetail,
      builder: (context, state) {
        final requestId = state.pathParameters['requestId'];
        if (requestId == null || requestId.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.dashboard);
          });
          return const Scaffold(body: Center(child: Text("Geçersiz Talep ID")));
        }
        return ManageDonationOffersScreen(requestId: requestId);
      },
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: '${AppRoutes.chat}/:chatId',
      name: AppRoutes.chat,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId'];
        if (chatId == null || chatId.isEmpty) {
          logger.e("Chat rotası için chatId eksik!");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.myChats);
          });
          return const Scaffold(body: Center(child: Text("Geçersiz Chat ID")));
        }

        final extra = state.extra as Map<String, dynamic>? ?? {};
        final queryParams = state.uri.queryParameters;

        final otherUserName =
            queryParams['otherUserName'] ??
            extra['otherUserName'] as String? ??
            'İsimsiz Kullanıcı';

        final otherUserAvatar =
            queryParams['otherUserAvatar'] ??
            extra['otherUserAvatar'] as String?;

        final requestId =
            queryParams['requestId'] ?? extra['requestId'] as String? ?? '';

        final otherUserId =
            queryParams['otherUserId'] ?? extra['otherUserId'] as String?;

        final contextId =
            queryParams['contextId'] ?? extra['contextId'] as String?;

        List<String> participantIds = [];
        final dynamic pIdsExtra = extra['participantIds'];
        if (pIdsExtra != null && pIdsExtra is List) {
          if (pIdsExtra.every((element) => element is String)) {
            participantIds = List<String>.from(pIdsExtra);
          } else {
            logger.w(
              "ChatScreen: 'participantIds' extra içinde string olmayan elemanlar içeriyor. Değer: $pIdsExtra",
            );
          }
        }

        if (participantIds.isEmpty) {
          logger.e(
            "ChatScreen: participantIds, extra'dan çıkarılmaya çalışıldıktan sonra boş. ChatId: $chatId. Bu durum mesaj göndermede sorunlara yol açacaktır.",
          );
        }

        logger.d(
          "Chat ekranı açılıyor: chatId=$chatId, otherUserName=$otherUserName, requestId=$requestId, otherUserId=$otherUserId, contextId=$contextId, participantIds=$participantIds",
        );

        return ChatScreen(
          chatId: chatId,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
          requestId: requestId,
          otherUserId: otherUserId,
          contextId: contextId,
          participantIds: participantIds,
        );
      },
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.donationCenters,
      name: AppRoutes.donationCenters,
      builder: (context, state) => const DonationCentersScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
    GoRoute(
      path: AppRoutes.map,
      name: AppRoutes.map,
      builder: (context, state) => const MapScreen(),
      parentNavigatorKey: rootNavigatorKey,
    ),
  ];

  // --- Hata Sayfası (statik) ---
  static Widget errorPage(
    BuildContext context,
    GoRouterState state, [
    Object? customError,
  ]) {
    final error = customError ?? state.error;
    logger.e(
      "GoRouter Hata: Rota bulunamadı veya hata oluştu. Path: ${state.uri}",
      error: error,
      stackTrace: (error is Error) ? error.stackTrace : null,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Hata Oluştu')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Beklenmedik bir hata oluştu veya aradığınız sayfa bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              if (kDebugMode && error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hata Detayı: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.splash),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Navigasyon Olaylarını Loglamak İçin Observer ---
class GoRouterObserver extends NavigatorObserver {
  String _getRouteName(Route<dynamic>? route) {
    if (route == null) {
      return 'null route';
    }
    final Object? settings = route.settings;
    if (settings is GoRoute) {
      return settings.path;
    }
    return route.settings.name ?? route.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final currentRouteName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);
    logger.t(
      'GoRouter: Pushed $currentRouteName${previousRouteName != 'null route' ? ' from $previousRouteName' : ''}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final currentRouteName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);
    logger.t(
      'GoRouter: Popped $currentRouteName${previousRouteName != 'null route' ? '. New top: $previousRouteName' : ''}',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newRouteName = _getRouteName(newRoute);
    final oldRouteName = _getRouteName(oldRoute);
    logger.t('GoRouter: Replaced $oldRouteName with $newRouteName');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final currentRouteName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);
    logger.t(
      'GoRouter: Removed $currentRouteName${previousRouteName != 'null route' ? '. Previous: $previousRouteName' : ''}',
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
