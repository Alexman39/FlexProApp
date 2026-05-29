import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style (dark icons on light, light icons on dark)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Enable edge-to-edge rendering
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Init local storage
  await Hive.initFlutter();
  await Hive.openBox<String>('workout_logs');
  await Hive.openBox<String>('enrollment');

  runApp(
    const ProviderScope(
      child: FlexProApp(),
    ),
  );
}
