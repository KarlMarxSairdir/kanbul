import 'package:riverpod_annotation/riverpod_annotation.dart'; // Ekle
import 'package:kan_bul/features/auth/domain/auth_service.dart';
import 'package:kan_bul/core/services/firebase_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ekle

part 'auth_service_provider.g.dart'; // Ekle

/// AuthService için provider - @riverpod ile yeniden yazıldı
@riverpod // Anotasyonu ekle
AuthService authService(Ref ref) {
  // Fonksiyon tanımı
  // Yine firebaseAuthServiceProvider'ı izle
  return ref.watch(firebaseAuthServiceProvider);
}
