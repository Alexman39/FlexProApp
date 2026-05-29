import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exercise_database.dart';
import '../domain/exercise_model.dart';

// ── Filter state ──────────────────────────────────────────

class ExerciseFilter {
  const ExerciseFilter({
    this.query = '',
    this.category,
    this.equipment,
  });

  final String query;
  final MuscleCategory? category;
  final Equipment? equipment;

  ExerciseFilter copyWith({
    String? query,
    Object? category = _sentinel,
    Object? equipment = _sentinel,
  }) =>
      ExerciseFilter(
        query: query ?? this.query,
        category: category == _sentinel ? this.category : category as MuscleCategory?,
        equipment: equipment == _sentinel ? this.equipment : equipment as Equipment?,
      );
}

const _sentinel = Object();

class ExerciseFilterNotifier extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() => const ExerciseFilter();

  void setQuery(String q) => state = state.copyWith(query: q.trim());

  void setCategory(MuscleCategory? c) => state = state.copyWith(category: c);

  void setEquipment(Equipment? e) => state = state.copyWith(equipment: e);

  void reset() => state = const ExerciseFilter();
}

final exerciseFilterProvider =
    NotifierProvider<ExerciseFilterNotifier, ExerciseFilter>(
        ExerciseFilterNotifier.new);

// ── Filtered exercise list ────────────────────────────────

final filteredExercisesProvider = Provider<List<ExerciseModel>>((ref) {
  final filter = ref.watch(exerciseFilterProvider);
  var list = kExerciseDatabase;

  if (filter.category != null) {
    list = list.where((e) => e.muscleCategory == filter.category).toList();
  }

  if (filter.equipment != null) {
    list = list.where((e) => e.equipment == filter.equipment).toList();
  }

  if (filter.query.isNotEmpty) {
    final q = filter.query.toLowerCase();
    list = list
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.primaryMuscle.label.toLowerCase().contains(q) ||
            e.secondaryMuscles.any((m) => m.label.toLowerCase().contains(q)))
        .toList();
  }

  return list..sort((a, b) => a.name.compareTo(b.name));
});

// ── Favorites ─────────────────────────────────────────────

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

// ── Single exercise lookup ────────────────────────────────

final exerciseByIdProvider = Provider.family<ExerciseModel?, String>((ref, id) {
  try {
    return kExerciseDatabase.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});
