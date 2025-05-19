// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart'; // <<< GoRouter importu EKLENDİ
import 'package:kan_bul/core/theme/app_theme.dart'; // Tema importu güncellendi

class App extends StatelessWidget {
  // <<< YENİ: GoRouter parametresi eklendi >>>
  final GoRouter router;

  // <<< DEĞİŞİKLİK: Constructor güncellendi >>>
  const App({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KanBul',
      theme: AppTheme.lightTheme, // Modern ve tutarlı tema kullanımı
      debugShowCheckedModeBanner: false,

      // Localization desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      locale: const Locale('tr', 'TR'),
      // <<< DEĞİŞİKLİK: Parametreden gelen router kullanıldı >>>
      routerConfig: router,
    );
  }
}
