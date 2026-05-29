import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/firestore_enrollment_repository.dart';
import '../domain/enrollment_model.dart';

// ── Local Hive fallback (used when not authenticated) ─────
class _LocalEnrollmentRepository {
  static const _box = 'enrollment';
  static const _key = 'active';

  ProgramEnrollment? get() {
    final s = Hive.box<String>(_box).get(_key);
    if (s == null) return null;
    try { return ProgramEnrollment.fromJsonString(s); } catch (_) { return null; }
  }

  Future<void> save(ProgramEnrollment e) async =>
      Hive.box<String>(_box).put(_key, e.toJsonString());

  Future<void> clear() async => Hive.box<String>(_box).delete(_key);
}

final _localEnrollmentRepoProvider =
    Provider<_LocalEnrollmentRepository>((_) => _LocalEnrollmentRepository());

// ── Notifier ──────────────────────────────────────────────
class EnrollmentNotifier extends AsyncNotifier<ProgramEnrollment?> {
  @override
  Future<ProgramEnrollment?> build() async {
    final firestoreRepo = ref.watch(firestoreEnrollmentRepoProvider);
    if (firestoreRepo != null) {
      return firestoreRepo.get();
    }
    return ref.read(_localEnrollmentRepoProvider).get();
  }

  Future<void> enroll(String programId) async {
    final enrollment = ProgramEnrollment(
      programId: programId,
      startedAt: DateTime.now(),
    );
    final firestoreRepo = ref.read(firestoreEnrollmentRepoProvider);
    if (firestoreRepo != null) {
      await firestoreRepo.save(enrollment);
    } else {
      await ref.read(_localEnrollmentRepoProvider).save(enrollment);
    }
    state = AsyncData(enrollment);
  }

  Future<void> unenroll() async {
    final firestoreRepo = ref.read(firestoreEnrollmentRepoProvider);
    if (firestoreRepo != null) {
      await firestoreRepo.clear();
    } else {
      await ref.read(_localEnrollmentRepoProvider).clear();
    }
    state = const AsyncData(null);
  }

  Future<void> completeSession(String logId, {required int daysPerWeek}) async {
    final e = state.valueOrNull;
    if (e == null) return;

    final newDay = e.currentDay + 1;
    final advanced = newDay >= daysPerWeek;
    final updated = e.copyWith(
      currentDay: advanced ? 0 : newDay,
      currentWeek: advanced ? e.currentWeek + 1 : e.currentWeek,
      completedSessionIds: [...e.completedSessionIds, logId],
    );

    final firestoreRepo = ref.read(firestoreEnrollmentRepoProvider);
    if (firestoreRepo != null) {
      await firestoreRepo.save(updated);
    } else {
      await ref.read(_localEnrollmentRepoProvider).save(updated);
    }
    state = AsyncData(updated);
  }
}

final enrollmentProvider =
    AsyncNotifierProvider<EnrollmentNotifier, ProgramEnrollment?>(
        EnrollmentNotifier.new);
