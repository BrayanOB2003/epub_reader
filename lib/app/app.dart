import 'package:epub_reader/app/router.dart';
import 'package:flutter/material.dart';

class EpubReaderApp extends StatelessWidget {
  const EpubReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4F3A), surface: const Color(0xFFF7F1E8)),
        scaffoldBackgroundColor: const Color(0xFFF7F1E8),
      ),
      routerConfig: appRouter,
    );
  }
}
