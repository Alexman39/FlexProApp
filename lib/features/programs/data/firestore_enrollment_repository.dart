import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_availability.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/enrollment_model.dart';

class FirestoreEnrollmentRepository {
  FirestoreEnrollmentRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(_uid);

  Future<ProgramEnrollment?> get() async {
    final snap = await _doc.get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final programId = data['enrolledProgramId'] as String?;
    if (programId == null) return null;

    return ProgramEnrollment(
      programId: programId,
      startedAt: (data['enrollmentStartedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      currentWeek: data['currentWeek'] as int? ?? 0,
      currentDay: data['currentDay'] as int? ?? 0,
      completedSessionIds:
          List<String>.from(data['completedSessionIds'] as List? ?? []),
    );
  }

  Future<void> save(ProgramEnrollment e) async {
    await _doc.update({
      'enrolledProgramId': e.programId,
      'enrollmentStartedAt': Timestamp.fromDate(e.startedAt),
      'currentWeek': e.currentWeek,
      'currentDay': e.currentDay,
      'completedSessionIds': e.completedSessionIds,
    });
  }

  Future<void> clear() async {
    await _doc.update({
      'enrolledProgramId': null,
      'enrollmentStartedAt': null,
      'currentWeek': 0,
      'currentDay': 0,
      'completedSessionIds': [],
    });
  }
}

// ── Provider ──────────────────────────────────────────────

final firestoreEnrollmentRepoProvider =
    Provider<FirestoreEnrollmentRepository?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = ref.read(firestoreProvider);
  if (db == null) return null;
  return FirestoreEnrollmentRepository(db, uid);
});
