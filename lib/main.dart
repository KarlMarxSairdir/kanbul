// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kan_bul/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/routes/router_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/core/providers/auth_state.dart';
import 'package:kan_bul/core/theme/app_theme.dart'; // Tema importu eklendi

// Arka planda gelen bildirimleri işlemek için üst düzey bir fonksiyon.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.d(
    "Arka plan mesajı alındı (main): ${message.messageId}, Data: ${message.data}",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  configureLogger(isProduction: false);

  try {
    runApp(const ProviderScope(child: KanBulAppInitializer()));
  } catch (e, s) {
    logger.f(
      "Uygulama başlatılırken yakalanamayan hata",
      error: e,
      stackTrace: s,
    );
    runApp(const ProviderScope(child: ErrorApp()));
  }
}

// NotificationService'i başlatmak için yeni bir widget
class KanBulAppInitializer extends ConsumerStatefulWidget {
  const KanBulAppInitializer({super.key});

  @override
  ConsumerState<KanBulAppInitializer> createState() =>
      _KanBulAppInitializerState();
}

class _KanBulAppInitializerState extends ConsumerState<KanBulAppInitializer> {
  @override
  void initState() {
    super.initState();
    Future(() async {
      // notificationServiceProvider yerine notificationServicePod kullanılacak (build_runner sonrası)
      // Şimdilik eski provider adını kullanıyoruz, build_runner sonrası bu satır güncellenmeli.
      final notificationServ = ref.read(notificationServiceProvider);
      await notificationServ.initialize();
      logger.i("NotificationService initialized via KanBulAppInitializer");
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateNotifierProvider, (
      AuthState? previousState,
      AuthState currentState,
    ) {
      // notificationServiceProvider yerine notificationServicePod kullanılacak (build_runner sonrası)
      // Şimdilik eski provider adını kullanıyoruz, build_runner sonrası bu satır güncellenmeli.
      final notificationServ = ref.read(notificationServiceProvider);
      final currentUser = currentState.user;
      if (currentUser != null) {
        logger.d(
          "AuthState değişti (Initializer - build): Kullanıcı mevcut: ${currentUser.id}. Token yönetimi AuthStateNotifier içinde.",
        );
        // saveTokenToFirestore çağrısı buradan kaldırıldı.
      } else {
        logger.d(
          "AuthState değişti (Initializer - build): Kullanıcı yok. Token silme işlemi tetikleniyor.",
        );
        notificationServ.deleteTokenFromFirestore();
      }
    });

    return const KanBulApp();
  }
}

class KanBulApp extends ConsumerWidget {
  const KanBulApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'KanBul',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme, // Modern ve tutarlı tema kullanımı
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      locale: const Locale('tr', 'TR'),
    );
  }
}

/// A minimal app to show when there's a critical error during initialization
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KanBul - Hata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      locale: const Locale('tr', 'TR'),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Uygulama başlatılırken bir hata oluştu',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Lütfen daha sonra tekrar deneyin veya desteğe başvurun',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    logger.i('Retrying Firebase initialization...');
                    await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                    logger.i('Firebase re-initialized successfully.');
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const ProviderScope(child: KanBulApp()),
                      ),
                    );
                  } catch (e, s) {
                    logger.e('Retry failed', error: e, stackTrace: s);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tekrar denemede hata oluştu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
