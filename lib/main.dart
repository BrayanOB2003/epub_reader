import 'package:epub_reader/app/app.dart';
import 'package:epub_reader/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const ProviderScope(child: EpubReaderApp()));
}

Future<void> _initializeFirebase() async {
  if (kIsWeb) return;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return;
  }
}
