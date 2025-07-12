import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod eklendi
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthStateNotifier'ı geri ekle
import 'package:kan_bul/features/auth/providers/auth_action_notifier.dart'; // AuthActionNotifier
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isSendingVerification = false;
  bool _isCheckingVerification = false; // Doğrulama kontrolü için yeni durum
  Timer? _timer;
  Timer? _periodicTimer;
  bool _canResend = true;
  int _start = 60;
  bool _disposed = false;
  bool _verificationCompleted = false;

  @override
  void initState() {
    super.initState();
    logger.d("EmailVerificationScreen: initState");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      // Ekran ilk açıldığında e-postayı gönder ve zamanlayıcıyı başlat.
      // _initializeScreen içinde _sendVerificationEmail çağrılacak.
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    if (_disposed) return;

    _refreshAndCheckEmail(
      isInitialLoad: true,
    ); // isInitialLoad true olarak gönderiliyor
    _startPeriodicCheck();
  }

  Future<void> _refreshAndCheckEmail({bool isInitialLoad = false}) async {
    if (_disposed) return;

    try {
      // AuthStateNotifier'ı kullanmaya devam et
      await ref.read(authStateNotifierProvider.notifier).refreshUser();
      if (_disposed) return;

      // AuthStateNotifier'ı kullanmaya devam et
      final authState = ref.read(authStateNotifierProvider);
      if (authState.user != null && !authState.user!.emailVerified) {
        // Sadece ilk yüklemede ve _canResend true ise otomatik gönder.
        // Kullanıcı zaten "yeniden gönder" butonuna basmışsa _canResend false olur ve tekrar göndermez.
        if (isInitialLoad && _canResend) {
          // showSnackbar: false çünkü bu otomatik bir gönderim.
          // _sendVerificationEmail zaten _startTimer'ı çağıracak.
          _sendVerificationEmail(showSnackbar: false);
        }
      } else if (authState.user != null && authState.user!.emailVerified) {
        setState(() => _verificationCompleted = true);
        _navigateToNextScreen();
      }
    } catch (e) {
      if (!_disposed) {
        logger.e(
          "Email doğrulama kontrolünde hata (refreshAndCheckEmail):",
          error: e,
        );
      }
    }
  }

  @override
  void dispose() {
    logger.d("EmailVerificationScreen: dispose");
    _disposed = true;
    _timer?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();

    if (_disposed) return;

    // Her 3 saniyede bir kontrol etmek için timer başlat
    _periodicTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      // Email doğrulama durumunu kontrol et
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    if (_disposed || _verificationCompleted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      logger.w("E-posta durumu kontrol edilemedi: Kullanıcı bulunamadı.");
      return;
    }

    try {
      // ÖNEMLİ: Her kontrol öncesinde Firebase user'ı yeniden yükle
      // Bu, doğrulama durumunu güncel olarak almamızı sağlar
      await currentUser.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        logger.w("Yenileme sonrası kullanıcı bulunamadı.");
        return;
      }

      final isVerified = refreshedUser.emailVerified;
      logger.d("E-posta doğrulama durumu: $isVerified");

      if (isVerified) {
        // ÖNEMLİ DEĞİŞİKLİK: refreshUser() çağrısını bu bloğun içine taşıdık.
        // Sadece ve sadece e-posta doğrulandıktan sonra Firestore'dan veri çekiyoruz.
        await ref.read(authStateNotifierProvider.notifier).refreshUser();

        if (_disposed) return;

        // Doğrulama tamamlandı, zamanlayıcıları durdur
        _periodicTimer?.cancel();
        _timer?.cancel();
        setState(() => _verificationCompleted = true);

        logger.i("E-posta doğrulandı! Bir sonraki ekrana yönlendiriliyor.");
        _navigateToNextScreen();
      }
      // else bloğuna gerek yok. Eğer doğrulanmadıysa, timer bir sonraki sefer tekrar çalışacak.
    } catch (e) {
      if (!_disposed) {
        logger.e("E-posta doğrulama durumu kontrol edilirken hata:", error: e);
      }
    }
  }

  // E-posta doğrulama durumunu manuel olarak kontrol et
  Future<void> _manuallyCheckVerification() async {
    if (_disposed || _verificationCompleted || _isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      // ÖNEMLİ: Firebase Auth kullanıcısını yeniden yükle
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isCheckingVerification = false;
        });
        return;
      }

      await firebaseUser.reload();

      // Kullanıcıyı tekrar al (reload sonrası)
      final updatedFirebaseUser = FirebaseAuth.instance.currentUser;

      if (updatedFirebaseUser == null) {
        logger.w("E-posta kontrolü: Kullanıcı bulunamadı");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isCheckingVerification = false;
        });
        return;
      }

      final isVerified = updatedFirebaseUser.emailVerified;
      logger.d("Manuel e-posta doğrulama kontrolü: $isVerified");

      if (isVerified) {
        // Doğrulama başarılı, sadece şimdi Firestore'dan veri çek
        final notifier = ref.read(authStateNotifierProvider.notifier);
        await notifier.refreshUser(); // Kullanıcı modelini güncelle

        setState(() {
          _verificationCompleted = true;
          _isCheckingVerification = false;
        });

        // Bir sonraki ekrana geç
        _navigateToNextScreen();
      } else {
        // Doğrulanmamış
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'E-posta hâlâ doğrulanmamış. Lütfen gelen kutunuzu kontrol edin.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isCheckingVerification = false;
        });
      }
    } catch (e) {
      logger.e("Manuel doğrulama kontrolünde hata:", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama kontrolünde hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!_disposed) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  // Doğrulama tamamlandıktan sonra bir sonraki ekrana git
  void _navigateToNextScreen() {
    if (!mounted || _disposed) return;

    // İzin ekranına yönlendir (doğrudan permission_request_screen)
    context.go(AppRoutes.permissionRequest);
  }

  void _startTimer() {
    if (_disposed) return;

    setState(() {
      _canResend = false;
      _start = 60;
    });

    _timer?.cancel(); // Mevcut sayacı iptal et

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      if (_start == 0) {
        if (!_disposed) {
          setState(() {
            _canResend = true;
          });
        }
        timer.cancel();
      } else {
        if (!_disposed) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  Future<void> _sendVerificationEmail({bool showSnackbar = true}) async {
    if (_disposed) return;

    if (_isSendingVerification) return;

    setState(() {
      _isSendingVerification = true;
    });

    try {
      await ref
          .read(authActionNotifierProvider.notifier)
          .sendEmailVerification();

      if (_disposed) return;

      if (showSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama e-postası gönderildi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _startTimer();
    } catch (e) {
      if (_disposed) return;
      logger.e("Doğrulama e-postası gönderilemedi:", error: e);
      if (showSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-posta gönderilemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (!_disposed) {
        setState(() {
          _isSendingVerification = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    if (_disposed) return;
    try {
      await ref.read(authActionNotifierProvider.notifier).signOut();
      if (_disposed) return;
      logger.i("Çıkış yapıldı, AuthWrapper yönlendirecek.");
    } catch (e) {
      if (_disposed) return;
      logger.e("Çıkış yapılamadı:", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılamadı: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth state değişimlerini dinle
    final authState = ref.watch(authStateNotifierProvider);

    // Eğer email doğrulandıysa yönlendirme yapmaya hazır olduğunu göster
    if (_verificationCompleted) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('E-posta doğrulaması tamamlandı! Yönlendiriliyor...'),
            ],
          ),
        ),
      );
    }

    // Normal ekranı göster
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Çıkış yapmak istediğini sor
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Çıkış Yap'),
                  content: const Text(
                    'Çıkış yapmak istediğinize emin misiniz? E-posta doğrulaması tamamlanmadı.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _signOut();
                      },
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-posta Doğrulama'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Çıkış yapmak istediğini sor
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Çıkış Yap'),
                        content: const Text(
                          'Çıkış yapmak istediğinize emin misiniz? E-posta doğrulaması tamamlanmadı.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _signOut();
                            },
                            child: const Text('Çıkış Yap'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                Text(
                  'E-posta Adresinizi Doğrulayın',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hesabınızı aktifleştirmek için lütfen ${authState.user?.email ?? 'e-posta adresinize'} gönderilen doğrulama e-postasındaki bağlantıya tıklayın.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '1. E-posta gelen kutunuzu kontrol edin\n'
                          '2. "E-posta Adresinizi Doğrulayın" konulu e-postayı bulun\n'
                          '3. E-postadaki "E-posta Adresimi Doğrula" butonuna tıklayın\n'
                          '4. Doğrulama tamamlandığında otomatik olarak yönlendirileceksiniz',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _canResend
                                        ? () => _sendVerificationEmail(
                                          showSnackbar: true,
                                        )
                                        : null,
                                icon: const Icon(Icons.send),
                                label:
                                    _isSendingVerification
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                        : Text(
                                          _canResend
                                              ? 'Yeniden Gönder'
                                              : 'Yeniden Gönder ($_start)',
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // YENİ: Doğrulama kontrolü butonu
                ElevatedButton.icon(
                  onPressed:
                      _isCheckingVerification
                          ? null
                          : _manuallyCheckVerification,
                  icon:
                      _isCheckingVerification
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                          : const Icon(Icons.check_circle),
                  label: const Text('E-posta Doğrulamayı Kontrol Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Doğrulama e-postasındaki bağlantıya tıkladıktan sonra "E-posta Doğrulamayı Kontrol Et" butonuna basın',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'E-posta bulunamadı mı?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Spam veya gereksiz klasörünüzü kontrol edin\n'
                          '• Doğru e-posta adresi kullandığınızdan emin olun\n'
                          '• Birkaç dakika bekleyin ve "Yeniden Gönder" tuşuna basın',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Add bottom padding for scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }
}
