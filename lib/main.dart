import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      final config = PurchasesConfiguration('test_FUcEakasJeeSPewEJUzctYWHgGQ');
      await Purchases.configure(config);
      debugPrint('RevenueCat configured.');

      // Identify already-signed-in user so their customer record appears
      // in the RevenueCat dashboard immediately on launch.
      if (firebaseAvailable) {
        final user = await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (user != null) {
          await Purchases.logIn(user.uid);
          debugPrint('RevenueCat: identified user ${user.uid}');
        }
      }
    } catch (e) {
      debugPrint('RevenueCat error: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(firebaseAvailable),
      ],
      child: const FlexProApp(),
    ),
  );
}
