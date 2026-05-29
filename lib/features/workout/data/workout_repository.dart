import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/workout_log_model.dart';

const _boxName = 'workout_logs';

class WorkoutRepository {
  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> save(WorkoutLog log) async {
    await _box.put(log.id, log.toJsonString());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<WorkoutLog> getAll() {
    return _box.values
        .map((s) {
          try {
            return WorkoutLog.fromJsonString(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<WorkoutLog>()
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  WorkoutLog? getById(String id) {
    final s = _box.get(id);
    if (s == null) return null;
    try {
      return WorkoutLog.fromJsonString(s);
    } catch (_) {
      return null;
    }
  }

  List<WorkoutLog> getForProgram(String programId) {
    return getAll().where((l) => l.programId == programId).toList();
  }
}

final workoutRepositoryProvider = Provider<WorkoutRepository>((_) => WorkoutRepository());

// ── Workout history list provider ──────────────────────────
class WorkoutHistoryNotifier extends Notifier<List<WorkoutLog>> {
  @override
  List<WorkoutLog> build() =>
      ref.read(workoutRepositoryProvider).getAll();

  void refresh() {
    state = ref.read(workoutRepositoryProvider).getAll();
  }

  Future<void> delete(String id) async {
    await ref.read(workoutRepositoryProvider).delete(id);
    refresh();
  }
}

final workoutHistoryProvider =
    NotifierProvider<WorkoutHistoryNotifier, List<WorkoutLog>>(
        WorkoutHistoryNotifier.new);
