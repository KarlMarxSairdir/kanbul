import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kan_bul/core/utils/logger.dart';
import 'package:kan_bul/firebase_options.dart'; // DefaultFirebaseOptions için
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Ref için eklendi
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthStateNotifier için
import 'package:kan_bul/routes/router_provider.dart'; // routerProvider için eklendi
import 'package:kan_bul/routes/app_routes.dart'; // AppRoutes için eklendi
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

// Arka plan mesaj işleyicisi (NotificationService dışında, top-level olmalı)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.i(
    "Arka plan mesajı alındı (firebaseMessagingBackgroundHandler): ${message.messageId}, Data: ${message.data}",
  );
  // ÖNEMLİ: Arka planda veya sonlandırılmış durumda NotificationService instance'ı
  // doğrudan kullanılamaz. Yerel bildirim göstermek için ya bu fonksiyon içinde
  // FlutterLocalNotificationsPlugin'i tekrar başlatıp göstermelisiniz ya da
  // sadece data payload'ı olan bildirimler için sistemin kendi bildirimini kullanmalısınız.
  // Bu örnekte, eğer mesajın 'notification' kısmı varsa sistem onu gösterir.
  // Sadece 'data' payload'u varsa ve arka planda özel bir yerel bildirim
  // göstermek istiyorsanız, FlutterLocalNotificationsPlugin'i burada da kurmanız gerekir.
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Ref _ref;

  NotificationService(this._ref);

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'kan_bul_channel_id',
    'KanBul Bildirimleri',
    description: 'KanBul uygulaması için bildirim kanalı.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i(
        'Ön planda mesaj alındı: ${message.messageId}, Data: ${message.data}',
      );
      _showLocalNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        logger.i(
          'Uygulama kapalıyken gelen bildirimden açıldı: ${message.messageId}, Data: ${message.data}',
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleMessageNavigation(message.data);
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i(
        'Uygulama arka plandayken gelen bildirimden açıldı: ${message.messageId}, Data: ${message.data}',
      );
      _handleMessageNavigation(message.data);
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      logger.i("Yeni FCM Token: $newToken");
      saveTokenToFirestore(token: newToken);
    });
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('Kullanıcı bildirim izni verdi.');
    } else {
      logger.w('Kullanıcı bildirim iznini reddetti veya henüz vermedi.');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS için varsayılan izinleri isteyebiliriz.
    const DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Eski iOS için
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        final String? payload = notificationResponse.payload;
        logger.i('Yerel bildirim payload tıklandı: $payload');
        if (payload != null && payload.isNotEmpty) {
          _handleMessageNavigation({'routePath': payload});
        }
      },
      // onDidReceiveBackgroundNotificationResponse: backgroundNotificationResponseHandler, // Arka plan tıklamaları için
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    // Bildirim verisini ve data payload'unu al
    String? title = notification?.title;
    String? body = notification?.body;
    Map<String, dynamic> dataPayload = message.data;

    // Eğer notification payload'u yoksa, data payload'undan başlık ve gövde almayı dene
    if (title == null && dataPayload.containsKey('title')) {
      title = dataPayload['title'] as String?;
    }
    if (body == null && dataPayload.containsKey('body')) {
      body = dataPayload['body'] as String?;
    }

    // Eğer hala başlık veya gövde yoksa, varsayılan değerler ata
    title ??= 'KanBul Bildirimi';
    body ??= 'Yeni bir gelişme var.';

    if (notification != null || dataPayload.isNotEmpty) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/launcher_icon',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload:
            dataPayload['routePath'] as String? ??
            dataPayload['route'] as String?,
      );
    } else {
      logger.w(
        "Gösterilecek bildirim başlığı veya içeriği bulunamadı. Mesaj: ${message.toMap()}",
      );
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      logger.e("FCM Token alınamadı: $e");
      return null;
    }
  }

  Future<void> saveTokenToFirestore({String? token}) async {
    final authState = _ref.read(authStateNotifierProvider);
    final currentUser = authState.user;

    if (currentUser == null) {
      logger.w("Kullanıcı giriş yapmamış, FCM token kaydedilemedi.");
      return;
    }

    final String? fcmToken = token ?? await getFCMToken();
    if (fcmToken == null) {
      logger.e("FCM token alınamadı, Firestore'a kaydedilemiyor.");
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id);
      final userDoc = await userDocRef.get();
      List<String> tokens = [];
      if (userDoc.exists &&
          userDoc.data() != null &&
          userDoc.data()!.containsKey('fcmTokens')) {
        final fcmTokensData = userDoc.data()!['fcmTokens'];
        if (fcmTokensData is List) {
          tokens = List<String>.from(fcmTokensData.map((e) => e.toString()));
        }
      }

      if (!tokens.contains(fcmToken)) {
        tokens.add(fcmToken);
        await userDocRef.set({'fcmTokens': tokens}, SetOptions(merge: true));
        logger.i(
          "FCM token Firestore'a başarıyla kaydedildi/güncellendi: ${currentUser.id}",
        );
      } else {
        logger.i("FCM token zaten Firestore'da mevcut: ${currentUser.id}");
      }
    } catch (e, s) {
      logger.e(
        "FCM token Firestore'a kaydedilirken hata oluştu",
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> deleteTokenFromFirestore() async {
    final authState = _ref.read(authStateNotifierProvider);
    final currentUser = authState.user;

    if (currentUser == null) {
      logger.w("Kullanıcı zaten çıkış yapmış, token silme işlemi atlandı.");
      return;
    }

    final String? currentToken = await getFCMToken();
    if (currentToken == null) {
      logger.w("Silinecek mevcut FCM token bulunamadı.");
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id);
      await userDocRef.update({
        'fcmTokens': FieldValue.arrayRemove([currentToken]),
      });
      logger.i(
        "Mevcut FCM token'ı (${currentUser.id}) Firestore'dan silme denemesi yapıldı.",
      );
    } catch (e, s) {
      logger.e(
        "FCM token Firestore'dan silinirken hata oluştu",
        error: e,
        stackTrace: s,
      );
    }
  }

  void _handleMessageNavigation(Map<String, dynamic> data) {
    final String? type = data['type'] as String?;
    final String? routePath =
        data['routePath'] as String? ?? data['route'] as String?;

    logger.i(
      "Bildirimden yönlendirme işleniyor: Type=$type, RoutePath=$routePath, Data=$data",
    );

    final router = _ref.read(routerProvider);

    try {
      if (routePath == null && type == null) {
        logger.w(
          "Yönlendirme için 'routePath' veya 'type' bulunamadı. Data: $data. Dashboard'a yönlendiriliyor.",
        );
        router.go(AppRoutes.dashboard);
        return;
      }

      if (type == 'new_nearby_request') {
        final String? requestId = data['requestId'] as String?;
        if (requestId != null) {
          logger.d(
            "Yönlendiriliyor: ${AppRoutes.bloodRequestDetail}/$requestId",
          );
          router.push('${AppRoutes.bloodRequestDetail}/$requestId');
        } else {
          logger.w("new_nearby_request için 'requestId' eksik. Data: $data");
          router.go(AppRoutes.dashboard);
        }
      } else if (type == 'new_donation_offer') {
        final String? requestId = data['requestId'] as String?;
        if (requestId != null) {
          logger.d(
            "Yönlendiriliyor: ${AppRoutes.manageDonationOffersDetail}/$requestId",
          );
          router.pushNamed(
            AppRoutes.manageDonationOffersDetail,
            pathParameters: {'requestId': requestId},
          );
        } else {
          logger.w("new_donation_offer için 'requestId' eksik. Data: $data");
          router.go(AppRoutes.dashboard);
        }
      } else if (type == 'offer_accepted') {
        final String? chatId = data['chatId'] as String?;
        if (chatId != null) {
          logger.d("Yönlendiriliyor: ${AppRoutes.chat} (Chat ID: $chatId)");
          router.pushNamed(
            AppRoutes.chat,
            pathParameters: {'chatId': chatId},
            extra: {
              'otherUserId': data['otherUserId'] as String?,
              'otherUserName': data['otherUserName'] as String?,
              'requestId': data['requestIdForChat'] as String?,
              'contextId': data['contextIdForChat'] as String?,
              'otherUserAvatar': data['otherUserAvatar'] as String?,
            },
          );
        } else {
          logger.w("offer_accepted için 'chatId' eksik. Data: $data");
          router.go(AppRoutes.dashboard);
        }
      } else if (type == 'donation_eligibility_reminder' && routePath != null) {
        logger.d("Yönlendiriliyor: $routePath (Uygunluk Hatırlatması)");
        router.go(routePath);
      } else if (routePath != null) {
        logger.i("Genel yönlendirme 'routePath' ile: $routePath");
        router.go(routePath);
      } else {
        logger.w(
          "Tanımlı bir yönlendirme kuralı eşleşmedi. Data: $data. Dashboard'a yönlendiriliyor.",
        );
        router.go(AppRoutes.dashboard);
      }
    } catch (e, s) {
      logger.e(
        "Bildirim yönlendirmesi sırasında GoRouter hatası: Data=$data",
        error: e,
        stackTrace: s,
      );
      try {
        router.go(AppRoutes.dashboard);
      } catch (_) {}
    }
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationService(ref);
  return service;
}
