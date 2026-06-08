import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase_availability.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  // ── Sign up ────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(displayName.trim());
    await _createUserDocument(cred.user!, displayName: displayName.trim());
  }

  // ── Sign in ────────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Google sign in ─────────────────────────────────────

  Future<void> signInWithGoogle() async {
    // Google Sign-In not supported on Linux desktop
    if (!kIsWeb && Platform.isLinux) {
      throw UnsupportedError(
          'Google Sign-In is not supported on Linux desktop.');
    }

    // serverClientId = web OAuth client from google-services.json (type 3).
    // Required on Android so that authentication.idToken is non-null.
    final googleUser = await GoogleSignIn(
      serverClientId:
          '956635335187-s0tsg1vm41oa2ghmvau46lbg9ki93m89.apps.googleusercontent.com',
    ).signIn();
    if (googleUser == null) throw Exception('Sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    if (cred.additionalUserInfo?.isNewUser == true) {
      await _createUserDocument(cred.user!);
    }
  }

  // ── Sign out ───────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn().signOut().catchError((_) {});
    await _auth.signOut();
  }

  // ── Helpers ────────────────────────────────────────────

  Future<void> _createUserDocument(User user, {String? displayName}) async {
    final name = displayName ?? user.displayName ?? user.email!.split('@').first;
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': name,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'enrolledProgramId': null,
      'enrollmentStartedAt': null,
      'currentWeek': 0,
      'currentDay': 0,
      'completedSessionIds': [],
    }, SetOptions(merge: true));
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Athlete',
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

// ── Providers ─────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  return FirebaseFirestore.instance;
});

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final db = ref.watch(firestoreProvider);
  if (auth == null || db == null) return null;
  return AuthRepository(auth, db);
});
