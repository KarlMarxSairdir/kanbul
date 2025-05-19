// lib/routes/router_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/core/providers/auth_state.dart';
import 'package:kan_bul/features/splash/presentation/screens/splash_screen.dart'; // Splash provider'ları için
import 'package:kan_bul/routes/app_router.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/core/providers/permission_provider.dart'; // İzin provider'ı
import 'package:kan_bul/data/models/user/user_model.dart';
import 'dart:async'; // StreamSubscription için
import 'package:kan_bul/core/enums/user_role.dart'; // Added import for UserRole

// Hem FirebaseAuth hem de Riverpod state'lerini dinleyen Notifier
class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  StreamSubscription<firebase_auth.User?>? _firebaseAuthSubscription;
  bool _isDisposed = false; // Dispose kontrolü için

  AppRouterNotifier(this._ref) {
    // 1. FirebaseAuth durumunu direkt dinle
    _firebaseAuthSubscription = firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebase_auth.User? user) {
          logger.d(
            "AppRouterNotifier: FirebaseAuth state changed (User: ${user?.uid}). Notifying.",
          );
          if (!_isDisposed) {
            notifyListeners(); // Auth durumu değişince router'ı tetikle
          }
        });

    // 2. AuthNotifier state'ini dinle (özellikle user nesnesi dolduğunda)
    _ref.listen<AuthState>(authStateNotifierProvider, (previous, next) {
      // Kullanıcı ID'si değiştiyse VEYA null'dan doluya geçtiyse VEYA email/izin durumu değiştiyse
      final userIdChanged = previous?.user?.id != next.user?.id;
      final becameLoggedIn = previous?.user == null && next.user != null;
      final becameLoggedOut = previous?.user != null && next.user == null;
      final emailStatusChanged =
          previous?.user?.emailVerified != next.user?.emailVerified;
      final permissionStatusChanged =
          previous?.user?.hasRequiredPermissions !=
          next.user?.hasRequiredPermissions;
      final isLoadingChanged = previous?.isLoading != next.isLoading;

      if (userIdChanged ||
          becameLoggedIn ||
          becameLoggedOut || // Çıkış durumunu ekle
          emailStatusChanged ||
          permissionStatusChanged ||
          isLoadingChanged) {
        logger.d(
          "AppRouterNotifier: AuthNotifier state changed significantly. "
          "userIdChanged=$userIdChanged, becameLoggedIn=$becameLoggedIn, becameLoggedOut=$becameLoggedOut, "
          "emailStatusChanged=$emailStatusChanged, permStatusChanged=$permissionStatusChanged. "
          "Now user=${next.user?.id}, emailVerified=${next.user?.emailVerified}, "
          "isLoading=${next.isLoading}. Notifying.",
        );
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    });

    // 3. İzin durumunu dinle
    _ref.listen<AsyncValue<bool>>(permissionCheckProvider, (previous, next) {
      final valueChanged = previous?.valueOrNull != next.valueOrNull;
      final loadingChanged = previous is AsyncLoading && next is! AsyncLoading;
      final errorChanged = previous?.hasError != next.hasError;

      if (valueChanged || loadingChanged || errorChanged) {
        logger.d(
          "AppRouterNotifier: Permission state changed: "
          "Value=${next.valueOrNull}, Loading=${next is AsyncLoading}, Error=${next.hasError}. Notifying.",
        );
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    });

    // 4. Splash başlatma durumunu dinle
    _ref.listen<bool>(splashInitCompleteProvider, (previous, next) {
      if (next && previous != next) {
        // Sadece false'tan true'ya geçince
        logger.d("AppRouterNotifier: Splash init complete. Notifying.");
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    });

    // 5. Onboarding durumunu dinle
    _ref.listen<bool>(onboardingSeenProvider, (previous, next) {
      if (previous != next) {
        logger.d(
          "AppRouterNotifier: Onboarding seen changed to $next. Notifying.",
        );
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _firebaseAuthSubscription?.cancel();
    super.dispose();
  }
}

// Notifier için provider
final appRouterNotifierProvider = Provider<AppRouterNotifier>((ref) {
  final notifier = AppRouterNotifier(ref);
  ref.onDispose(
    () => notifier.dispose(),
  ); // Dispose olduğunda notifier'ı da dispose et
  return notifier;
});

// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(appRouterNotifierProvider); // Yeni notifier'ı izle

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: AppRouter.rootNavigatorKey,
    refreshListenable: notifier, // YENİ NOTIFIER KULLANILDI
    redirect:
        (context, state) =>
            _redirect(ref, context, state), // Redirect fonksiyonu
    routes: AppRouter.routes,
    errorBuilder: (context, state) => AppRouter.errorPage(context, state),
    observers: [GoRouterObserver()],
    debugLogDiagnostics: true,
  );
});

// Yönlendirme mantığı (Sadece Notifier ve Provider'ları kullanır)
Future<String?> _redirect(
  Ref ref,
  BuildContext context,
  GoRouterState state,
) async {
  final location = state.matchedLocation;
  logger.d("Router Redirect Check: Current Location=$location");

  // Read all necessary providers at the beginning
  final authState = ref.read(authStateNotifierProvider);
  final permissionAsync = ref.read(permissionCheckProvider);
  final splashInitComplete = ref.read(splashInitCompleteProvider);
  final onboardingSeen = ref.read(onboardingSeenProvider);

  // Log initial states
  logger.d(
    "Router States: SplashInit=$splashInitComplete, OnboardingSeen=$onboardingSeen, "
    "AuthLoading=${authState.isLoading}, AuthUser=${authState.user?.id}, "
    "PermLoading=${permissionAsync.isLoading}, PermGranted=${permissionAsync.valueOrNull}",
  );

  // 1. Handle Splash Screen
  if (!splashInitComplete) {
    if (location == AppRoutes.splash) {
      logger.d("Redirect: Splash not complete, staying on Splash.");
      return null; // Stay on splash if not complete
    } else {
      logger.d("Redirect: Splash not complete, redirecting to Splash.");
      return AppRoutes.splash; // If not on splash, go to splash
    }
  }

  // If splash is complete and we are on splash, decide where to go next
  if (location == AppRoutes.splash && splashInitComplete) {
    if (!onboardingSeen) {
      logger.d("Redirect: Splash complete, onboarding not seen -> Onboarding");
      return AppRoutes.onboarding;
    }
    // If onboarding is seen, we'll proceed to auth checks.
    // No specific redirect here, let auth checks handle it.
    // This avoids redirecting to authWrapper prematurely if user is already null.
    logger.d(
      "Redirect: Splash complete, onboarding seen. Proceeding to auth checks.",
    );
  }

  // 2. Handle Onboarding
  if (!onboardingSeen) {
    // If splash is done, and onboarding not seen, should be on onboarding or go there.
    if (location != AppRoutes.onboarding) {
      logger.d("Redirect: Onboarding not seen, redirecting to Onboarding.");
      return AppRoutes.onboarding;
    }
    logger.d("Redirect: Onboarding not seen, staying on Onboarding.");
    return null; // Stay on onboarding screen
  }

  // If onboarding is seen and current location is onboarding, proceed to auth checks
  if (onboardingSeen && location == AppRoutes.onboarding) {
    logger.d(
      "Redirect: Onboarding seen, leaving Onboarding. Proceeding to auth checks.",
    );
    // No specific redirect here, let auth checks decide.
    // This avoids going to authWrapper if user is null etc.
  }

  // --- From this point, splash is complete and onboarding is seen ---

  // 3. Handle Auth State Loading
  if (authState.isLoading) {
    logger.d("Redirect: Auth state is loading. Staying on $location.");
    return null; // Wait for auth state to resolve
  }

  // Attempt to get Firebase user and reload
  final firebase_auth.User? fbUserBeforeReload =
      firebase_auth.FirebaseAuth.instance.currentUser;
  if (fbUserBeforeReload != null) {
    try {
      await fbUserBeforeReload.reload();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code != 'no-current-user' &&
          e.code != 'user-token-expired' &&
          e.code != 'user-disabled') {
        logger.e(
          "Firebase user reload error (non-critical for redirect)",
          error: e,
        );
      }
      // For critical errors like token expired or user disabled, fbUser will become null after next fetch.
    } catch (e) {
      logger.e("Firebase user reload general error", error: e);
    }
  }
  final firebase_auth.User? firebaseUser =
      firebase_auth.FirebaseAuth.instance.currentUser;
  final bool isFirebaseUserVerified = firebaseUser?.emailVerified ?? false;

  logger.d(
    "Router Firebase User: UID=${firebaseUser?.uid}, EmailVerified=$isFirebaseUserVerified",
  );
  logger.d(
    "Router AuthState User: UID=${authState.user?.id}, EmailVerified=${authState.user?.emailVerified}",
  );

  // 4. Handle No Authenticated User (Firebase User is Null)
  if (firebaseUser == null) {
    final allowedPublicRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      // Splash and Onboarding are handled above.
      // AuthWrapper should not be a destination if user is null.
    ];
    if (allowedPublicRoutes.contains(location)) {
      logger.d(
        "Redirect: No Firebase user, but on an allowed public page ($location). Staying.",
      );
      return null;
    }
    logger.d("Redirect: No Firebase user. Redirecting to Login.");
    return AppRoutes.login;
  }

  // --- Firebase User Exists ---

  // Sync AuthState with Firebase state if necessary (Simplified Check)
  // This is a tricky part. AuthStateNotifier should ideally keep itself in sync.
  // A full refreshUser() here can cause loops if not handled carefully.
  // We primarily rely on firebaseUser for critical checks like email verification.
  if (authState.user == null || authState.user!.id != firebaseUser.uid) {
    logger.w(
      "Redirect: AuthState user (${authState.user?.id}) is null or mismatched with Firebase user (${firebaseUser.uid}). "
      "AuthStateNotifier should sync. For now, proceeding with Firebase user data for critical checks. This might indicate a pending state update.",
    );
    // Potentially, if critical data for role-based routing is ONLY in authState.user,
    // and it's not yet loaded, we might need to return null here to wait.
    // For now, we assume email verification and permissions can be checked independently or wait.
    // If authState.isLoading was true, we would have returned null earlier.
    // Since it's false, we expect authState.user to be populated soon if firebaseUser exists.
  }

  // 5. Handle Email Verification
  if (!isFirebaseUserVerified) {
    if (location == AppRoutes.emailVerification) {
      logger.d(
        "Redirect: Email not verified, already on EmailVerificationScreen. Staying.",
      );
      return null;
    }
    logger.d(
      "Redirect: Email not verified. Redirecting to EmailVerificationScreen.",
    );
    return AppRoutes.emailVerification;
  }

  // --- Email is Verified ---

  // 6. Handle Permissions
  // Check if permissions are still loading (even if authState is not)
  if (permissionAsync.isLoading && !permissionAsync.hasValue) {
    logger.d("Redirect: Permissions are loading. Staying on $location.");
    return null;
  }

  final bool permissionsGranted = permissionAsync.valueOrNull ?? false;
  if (!permissionsGranted) {
    if (location == AppRoutes.permissionRequest) {
      logger.d(
        "Redirect: Email verified, permissions not granted, already on PermissionRequestScreen. Staying.",
      );
      return null;
    }
    logger.d(
      "Redirect: Email verified, permissions not granted. Redirecting to PermissionRequestScreen.",
    );
    return AppRoutes.permissionRequest;
  }

  // --- Email Verified and Permissions Granted ---
  logger.d(
    "Redirect: All checks passed (Splash, Onboarding, Auth, Email, Permissions).",
  );

  // 7. User is fully authenticated and authorized. Redirect from auth flow pages.
  final authFlowRoutes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.emailVerification,
    AppRoutes.permissionRequest,
    AppRoutes.authWrapper, // AuthWrapper is a transitional route
  ];

  if (authFlowRoutes.contains(location)) {
    logger.d(
      "Redirect: On an auth flow page ($location) after all checks. Determining dashboard...",
    );
    // Ensure authState.user is available for role check
    if (authState.user == null) {
      logger.w(
        "Redirect: AuthState.user is null even after all checks. This is unexpected. Staying on $location to avoid errors.",
      );
      // This case should ideally be caught by authState.isLoading or firebaseUser == null checks.
      // If we reach here, it implies a state inconsistency. Returning null to prevent crash.
      return null;
    }
    final userRole = authState.user!.role;
    logger.d("Redirect: User role is $userRole.");
    if (userRole == UserRole.hospitalStaff) {
      logger.d("Redirect: -> Hospital Dashboard");
      return AppRoutes.hospitalDashboard;
    } else {
      logger.d("Redirect: -> Individual Dashboard");
      return AppRoutes.dashboard;
    }
  }

  // If on a protected page and all checks passed, no redirection needed.
  logger.d(
    "Redirect: All checks passed, already on a protected page ($location) or a page not in auth flow. Staying.",
  );
  return null;
}

// GoRouter için izleyici sınıfı
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('GoRouter Pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('GoRouter Popped: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('GoRouter Removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.d(
      'GoRouter Replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
  }
}
