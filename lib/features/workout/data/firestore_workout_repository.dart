import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_availability.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/workout_log_model.dart';

class FirestoreWorkoutRepository {
  FirestoreWorkoutRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('workoutLogs');

  Future<void> save(WorkoutLog log) async {
    await _col.doc(log.id).set(_toFirestore(log));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<WorkoutLog>> watchAll() {
    return _col
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              try {
                return _fromFirestore(d.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<WorkoutLog>()
            .toList());
  }

  // ── Firestore ↔ model conversions ──────────────────────

  static Map<String, dynamic> _toFirestore(WorkoutLog log) => {
        'id': log.id,
        'workoutName': log.workoutName,
        'startedAt': Timestamp.fromDate(log.startedAt),
        'finishedAt': Timestamp.fromDate(log.finishedAt),
        'programId': log.programId,
        'programWeek': log.programWeek,
        'programDay': log.programDay,
        'notes': log.notes,
        'exercises': log.exercises.map((e) => {
              'exerciseId': e.exerciseId,
              'exerciseName': e.exerciseName,
              'sets': e.sets
                  .map((s) => {
                        'reps': s.reps,
                        'weight': s.weight,
                        'rpe': s.rpe,
                      })
                  .toList(),
            }).toList(),
      };

  static WorkoutLog _fromFirestore(Map<String, dynamic> d) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return DateTime.parse(v as String);
    }

    return WorkoutLog(
      id: d['id'] as String,
      workoutName: d['workoutName'] as String,
      startedAt: parseDate(d['startedAt']),
      finishedAt: parseDate(d['finishedAt']),
      programId: d['programId'] as String?,
      programWeek: d['programWeek'] as int?,
      programDay: d['programDay'] as int?,
      notes: d['notes'] as String?,
      exercises: (d['exercises'] as List)
          .map((e) => LoggedExercise(
                exerciseId: e['exerciseId'] as String,
                exerciseName: e['exerciseName'] as String,
                sets: (e['sets'] as List)
                    .map((s) => LoggedSet(
                          reps: s['reps'] as int,
                          weight: (s['weight'] as num).toDouble(),
                          rpe: s['rpe'] != null
                              ? (s['rpe'] as num).toDouble()
                              : null,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}

// ── Providers ─────────────────────────────────────────────

final firestoreWorkoutRepoProvider =
    Provider<FirestoreWorkoutRepository?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = ref.read(firestoreProvider);
  if (db == null) return null;
  return FirestoreWorkoutRepository(db, uid);
});

// ── Workout history stream ─────────────────────────────────
final workoutHistoryStreamProvider =
    StreamProvider<List<WorkoutLog>>((ref) {
  final repo = ref.watch(firestoreWorkoutRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAll();
});
