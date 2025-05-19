import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:flutter_animate/flutter_animate.dart'; // Animate paketi eklendi
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences eklendi
import 'package:firebase_core/firebase_core.dart';
import 'package:kan_bul/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Splash ekranı başlatma durumunu izleyen provider
final splashInitCompleteProvider = StateProvider<bool>((ref) => false);
// Onboarding durumunu tutan provider
final onboardingSeenProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    // İlk frame'i göstermeyi ertele
    WidgetsBinding.instance.deferFirstFrame();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      logger.d("SplashScreen: Initializing...");

      // Paralel olarak yapılabilecek başlatma işlemleri
      final futures = await Future.wait([
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        SharedPreferences.getInstance(),
        // Minimum splash süresini sağlamak için bekleme - ama çok uzun değil
        Future.delayed(1500.ms), // Süreyi biraz kısalttık
      ]);

      // SharedPreferences instance'ını alalım
      final prefs = futures[1] as SharedPreferences;
      final bool onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

      // Onboarding durumunu provider'a kaydet
      ref.read(onboardingSeenProvider.notifier).state = onboardingSeen;

      logger.d(
        "SplashScreen: Initialization complete in ${_stopwatch.elapsedMilliseconds}ms, onboardingSeen=$onboardingSeen",
      );

      // Başlatma bitti, ilk frame'in çizilmesine izin ver
      WidgetsBinding.instance.allowFirstFrame();

      _stopwatch.stop();

      // Navigasyon için biraz daha bekleyelim (animasyonların tamamlanması için)
      await Future.delayed(300.ms);

      if (mounted) {
        // Artık context.go() kullanmıyoruz. Bunun yerine:
        // Başlatma işleminin tamamlandığını bildir
        ref.read(splashInitCompleteProvider.notifier).state = true;
        logger.i("SplashScreen: Initialization complete, notified router.");
      }
    } catch (e, s) {
      logger.e("Splash Screen Hata:", error: e, stackTrace: s);

      // Hata durumunda da frame'i sal
      try {
        WidgetsBinding.instance.allowFirstFrame();
      } catch (_) {
        // allowFirstFrame zaten çağrılmışsa hata alınabilir, bunu görmezden geliyoruz
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Uygulama başlatılırken bir hata oluştu."),
            duration: Duration(seconds: 3),
          ),
        );

        // Hata durumunda da başlatma tamamlandı olarak işaretle
        // (router hatayı ele alacak)
        ref.read(splashInitCompleteProvider.notifier).state = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo1.png', width: 150)
                .animate()
                .fadeIn(duration: 600.ms)
                .then(delay: 100.ms)
                .scaleXY(
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                  begin: 0.5,
                  end: 1.0,
                )
                .then(delay: 800.ms)
                .fadeOut(duration: 300.ms),

            const SizedBox(height: 20),

            const Text(
                  "Hayat Ellerinde",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .then(delay: 1000.ms)
                .slideY(
                  begin: 0.5,
                  end: 0.0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                )
                .then(delay: 300.ms)
                .fadeOut(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
