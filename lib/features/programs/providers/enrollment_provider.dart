import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/enrollment_model.dart';

const _boxName = 'enrollment';
const _enrollmentKey = 'active';

// ── Repository ────────────────────────────────────────────
class EnrollmentRepository {
  Box<String> get _box => Hive.box<String>(_boxName);

  ProgramEnrollment? get() {
    final s = _box.get(_enrollmentKey);
    if (s == null) return null;
    try {
      return ProgramEnrollment.fromJsonString(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ProgramEnrollment e) async {
    await _box.put(_enrollmentKey, e.toJsonString());
  }

  Future<void> clear() async {
    await _box.delete(_enrollmentKey);
  }
}

final enrollmentRepositoryProvider =
    Provider<EnrollmentRepository>((_) => EnrollmentRepository());

// ── Notifier ──────────────────────────────────────────────
class EnrollmentNotifier extends Notifier<ProgramEnrollment?> {
  @override
  ProgramEnrollment? build() =>
      ref.read(enrollmentRepositoryProvider).get();

  Future<void> enroll(String programId) async {
    final enrollment = ProgramEnrollment(
      programId: programId,
      startedAt: DateTime.now(),
    );
    await ref.read(enrollmentRepositoryProvider).save(enrollment);
    state = enrollment;
  }

  Future<void> unenroll() async {
    await ref.read(enrollmentRepositoryProvider).clear();
    state = null;
  }

  Future<void> completeSession(String logId, {required int daysPerWeek}) async {
    final e = state;
    if (e == null) return;

    final newIds = [...e.completedSessionIds, logId];
    final newDay = e.currentDay + 1;
    final advanced = newDay >= daysPerWeek;

    final updated = e.copyWith(
      currentDay: advanced ? 0 : newDay,
      currentWeek: advanced ? e.currentWeek + 1 : e.currentWeek,
      completedSessionIds: newIds,
    );

    await ref.read(enrollmentRepositoryProvider).save(updated);
    state = updated;
  }
}

final enrollmentProvider =
    NotifierProvider<EnrollmentNotifier, ProgramEnrollment?>(
        EnrollmentNotifier.new);
