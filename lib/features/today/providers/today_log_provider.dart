import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workout/data/firestore_workout_repository.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout_log_model.dart';

/// Returns the WorkoutLog completed today (matching calendar date), or null.
final todaysCompletedLogProvider = Provider<WorkoutLog?>((ref) {
  final firestoreHistory = ref.watch(workoutHistoryStreamProvider).valueOrNull;
  final hiveHistory = ref.watch(workoutHistoryProvider);
  final allHistory = firestoreHistory ?? hiveHistory;
  final today = DateTime.now();
  return allHistory.where((log) {
    return log.startedAt.year == today.year &&
        log.startedAt.month == today.month &&
        log.startedAt.day == today.day;
  }).firstOrNull;
});
