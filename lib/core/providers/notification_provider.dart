import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

const _kEnabledKey = 'notif_enabled';
const _kHourKey    = 'notif_hour';
const _kMinuteKey  = 'notif_minute';

class NotificationSettings {
  const NotificationSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  NotificationSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(NotificationSettings initial) : super(initial);

  /// Returns false if the OS denied notification permission.
  Future<bool> setEnabled(
    bool enabled, {
    required String title,
    required String body,
  }) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) return false;
      await NotificationService.instance.scheduleDaily(
        time: state.time,
        title: title,
        body: body,
      );
    } else {
      await NotificationService.instance.cancel();
    }
    state = state.copyWith(enabled: enabled);
    await _persist();
    return true;
  }

  Future<void> setTime(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    state = state.copyWith(time: time);
    if (state.enabled) {
      await NotificationService.instance.scheduleDaily(
        time: time,
        title: title,
        body: body,
      );
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, state.enabled);
    await prefs.setInt(_kHourKey,     state.time.hour);
    await prefs.setInt(_kMinuteKey,   state.time.minute);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(
    const NotificationSettings(enabled: false, time: TimeOfDay(hour: 8, minute: 0)),
  ),
);

Future<NotificationSettings> loadNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(_kEnabledKey) ?? false;
  final hour    = prefs.getInt(_kHourKey)     ?? 8;
  final minute  = prefs.getInt(_kMinuteKey)   ?? 0;
  return NotificationSettings(
    enabled: enabled,
    time: TimeOfDay(hour: hour, minute: minute),
  );
}
