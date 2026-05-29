enum MuscleGroup {
  chest, upperChest, lowerChest,
  lats, traps, rhomboids, lowerBack,
  frontDelt, sideDelt, rearDelt,
  biceps, brachialis, triceps, forearms,
  quads, hamstrings, glutes, calves,
  abs, obliques, core,
}

extension MuscleGroupX on MuscleGroup {
  String get label => switch (this) {
    MuscleGroup.chest       => 'Chest',
    MuscleGroup.upperChest  => 'Upper Chest',
    MuscleGroup.lowerChest  => 'Lower Chest',
    MuscleGroup.lats        => 'Lats',
    MuscleGroup.traps       => 'Traps',
    MuscleGroup.rhomboids   => 'Rhomboids',
    MuscleGroup.lowerBack   => 'Lower Back',
    MuscleGroup.frontDelt   => 'Front Delt',
    MuscleGroup.sideDelt    => 'Side Delt',
    MuscleGroup.rearDelt    => 'Rear Delt',
    MuscleGroup.biceps      => 'Biceps',
    MuscleGroup.brachialis  => 'Brachialis',
    MuscleGroup.triceps     => 'Triceps',
    MuscleGroup.forearms    => 'Forearms',
    MuscleGroup.quads       => 'Quads',
    MuscleGroup.hamstrings  => 'Hamstrings',
    MuscleGroup.glutes      => 'Glutes',
    MuscleGroup.calves      => 'Calves',
    MuscleGroup.abs         => 'Abs',
    MuscleGroup.obliques    => 'Obliques',
    MuscleGroup.core        => 'Core',
  };

  // High-level filter category shown as chips in the library
  MuscleCategory get category => switch (this) {
    MuscleGroup.chest || MuscleGroup.upperChest || MuscleGroup.lowerChest => MuscleCategory.chest,
    MuscleGroup.lats || MuscleGroup.traps || MuscleGroup.rhomboids || MuscleGroup.lowerBack => MuscleCategory.back,
    MuscleGroup.frontDelt || MuscleGroup.sideDelt || MuscleGroup.rearDelt => MuscleCategory.shoulders,
    MuscleGroup.biceps || MuscleGroup.brachialis || MuscleGroup.triceps || MuscleGroup.forearms => MuscleCategory.arms,
    MuscleGroup.quads || MuscleGroup.hamstrings || MuscleGroup.glutes || MuscleGroup.calves => MuscleCategory.legs,
    MuscleGroup.abs || MuscleGroup.obliques || MuscleGroup.core => MuscleCategory.core,
  };
}

enum MuscleCategory {
  chest, back, shoulders, arms, legs, core;

  String get label => switch (this) {
    MuscleCategory.chest     => 'Chest',
    MuscleCategory.back      => 'Back',
    MuscleCategory.shoulders => 'Shoulders',
    MuscleCategory.arms      => 'Arms',
    MuscleCategory.legs      => 'Legs',
    MuscleCategory.core      => 'Core',
  };

  String get emoji => switch (this) {
    MuscleCategory.chest     => '🫀',
    MuscleCategory.back      => '🔙',
    MuscleCategory.shoulders => '🦾',
    MuscleCategory.arms      => '💪',
    MuscleCategory.legs      => '🦵',
    MuscleCategory.core      => '⚡',
  };
}

enum Equipment {
  barbell, dumbbell, cable, machine, bodyweight,
  kettlebell, resistanceBand, smithMachine, ezBar;

  String get label => switch (this) {
    Equipment.barbell       => 'Barbell',
    Equipment.dumbbell      => 'Dumbbell',
    Equipment.cable         => 'Cable',
    Equipment.machine       => 'Machine',
    Equipment.bodyweight    => 'Bodyweight',
    Equipment.kettlebell    => 'Kettlebell',
    Equipment.resistanceBand => 'Band',
    Equipment.smithMachine  => 'Smith',
    Equipment.ezBar         => 'EZ Bar',
  };
}

enum ExerciseCategory { compound, isolation }

extension ExerciseCategoryX on ExerciseCategory {
  String get label => switch (this) {
    ExerciseCategory.compound  => 'Compound',
    ExerciseCategory.isolation => 'Isolation',
  };
}

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.category,
    this.instructions,
    this.tips,
  });

  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final ExerciseCategory category;
  final String? instructions;
  final String? tips;

  MuscleCategory get muscleCategory => primaryMuscle.category;

  String get muscleDisplay {
    if (secondaryMuscles.isEmpty) return primaryMuscle.label;
    return '${primaryMuscle.label} · ${secondaryMuscles.take(2).map((m) => m.label).join(' · ')}';
  }
}
