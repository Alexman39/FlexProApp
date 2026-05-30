import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/firebase_availability.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Firebase is not supported on Linux desktop — skip init gracefully.
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseAvailable = true;
  } catch (_) {
    debugPrint('Firebase unavailable on this platform — running in local mode.');
  }

  await Hive.initFlutter();
  await Hive.openBox<String>('workout_logs');
  await Hive.openBox<String>('enrollment');
  await Hive.openBox<String>('body_weight');

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(firebaseAvailable),
      ],
      child: const FlexProApp(),
    ),
  );
}
