// lib/core/providers/shared_preferences_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'shared_preferences_provider.g.dart';

/// SharedPreferences örneğini sağlayan Riverpod provider'ı.
/// Uygulama boyunca canlı kalması için `keepAlive` true olarak ayarlanmıştır.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}
