import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True on Android/iOS where Firebase is fully supported.
/// False on Linux desktop — app runs in local-only mode.
final firebaseAvailableProvider = Provider<bool>((_) => false);
