import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_availability.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

// ── Raw Firebase auth state ────────────────────────────────
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final available = ref.watch(firebaseAvailableProvider);
  if (!available) return Stream.value(null);
  return ref.watch(authRepositoryProvider)!.authStateChanges;
});

// ── Typed app user (fetched from Firestore) ────────────────
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return null;
  return ref.read(authRepositoryProvider)?.fetchUser(user.uid);
});

// ── Simple bool — is the user signed in? ──────────────────
final isAuthenticatedProvider = Provider<bool>((ref) {
  final available = ref.watch(firebaseAvailableProvider);
  if (!available) return true; // local mode: treat as signed in
  return ref.watch(authStateChangesProvider).valueOrNull != null;
});

// ── Current Firebase UID ───────────────────────────────────
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull?.uid;
});
