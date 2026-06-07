import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkModeKey = 'is_dark_mode';

// Default dark — overridden at startup with persisted value.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

Future<void> persistThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kDarkModeKey, mode == ThemeMode.dark);
}

Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(_kDarkModeKey) ?? true;
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
