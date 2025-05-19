import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kan_bul/core/enums/user_role.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Kullanıcının sahip olduğu rollere göre FCM topic aboneliği
  Future<void> subscribeToRoleTopics(List<UserRole> roles) async {
    for (final role in roles) {
      await _messaging.subscribeToTopic(role.name);
    }
  }

  /// Kullanıcının rolleri değiştiğinde eski topic'lerden çık, yenilere abone ol
  Future<void> updateRoleTopics({
    required List<UserRole> oldRoles,
    required List<UserRole> newRoles,
  }) async {
    for (final role in oldRoles) {
      if (!newRoles.contains(role)) {
        await _messaging.unsubscribeFromTopic(role.name);
      }
    }
    for (final role in newRoles) {
      if (!oldRoles.contains(role)) {
        await _messaging.subscribeToTopic(role.name);
      }
    }
  }

  /// Çıkışta tüm topic aboneliklerini kaldır
  Future<void> unsubscribeFromAllTopics(List<UserRole> roles) async {
    for (final role in roles) {
      await _messaging.unsubscribeFromTopic(role.name);
    }
  }
}
