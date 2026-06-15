import 'package:flutter/material.dart';

// Web stub — flutter_local_notifications has no web implementation.
// All methods are no-ops; the profile screen notification toggle is hidden on web.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {}
  Future<bool> requestPermissions() async => false;
  Future<void> scheduleDaily({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {}
  Future<void> cancel() async {}
}
