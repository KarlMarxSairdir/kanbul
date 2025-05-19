import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthConfig {
  /// Firebase Auth konfigürasyonunu test için hazırlar
  static Future<void> configureForTesting() async {
    try {
      // Test modu için App Check ve reCAPTCHA'yı devre dışı bırak
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );

      debugPrint('Firebase Auth test modu etkinleştirildi');
    } catch (e) {
      debugPrint('Firebase Auth test modu etkinleştirilemedi: $e');
    }
  }
}
