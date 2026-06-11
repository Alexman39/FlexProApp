// ── Domain models for onboarding questionnaire ──────────
import 'package:flutter/material.dart';

enum TrainingGoal {
  hypertrophy('Hypertrophy',    'Build muscle mass and size'),
  strength   ('Strength',       'Maximize your lifts'),
  fatLoss    ('Fat Loss',       'Lean out while preserving muscle'),
  recomp     ('Recomposition',  'Build muscle and lose fat simultaneously'),
  general    ('General Fitness','Look, feel, and perform better');

  const TrainingGoal(this.label, this.description);
  final String label;
  final String description;

  IconData get icon => switch (this) {
    TrainingGoal.hypertrophy => Icons.fitness_center_rounded,
    TrainingGoal.strength    => Icons.emoji_events_rounded,
    TrainingGoal.fatLoss     => Icons.local_fire_department_rounded,
    TrainingGoal.recomp      => Icons.balance_rounded,
    TrainingGoal.general     => Icons.sports_gymnastics_rounded,
  };
}

enum ExperienceLevel {
  beginner    ('Beginner',     'Less than 1 year of consistent training'),
  intermediate('Intermediate', '1–3 years of consistent training'),
  advanced    ('Advanced',     '3+ years, know your body well');

  const ExperienceLevel(this.label, this.description);
  final String label;
  final String description;

  IconData get icon => switch (this) {
    ExperienceLevel.beginner     => Icons.school_rounded,
    ExperienceLevel.intermediate => Icons.trending_up_rounded,
    ExperienceLevel.advanced     => Icons.military_tech_rounded,
  };
}

enum EquipmentAccess {
  fullGym    ('Full Gym',       'All equipment, cables, machines, free weights'),
  homeGym    ('Home Gym',       'Barbells, dumbbells, some machines'),
  dumbbells  ('Dumbbells Only', 'Just dumbbells and a bench'),
  bodyweight ('Bodyweight',     'No equipment needed');

  const EquipmentAccess(this.label, this.description);
  final String label;
  final String description;

  IconData get icon => switch (this) {
    EquipmentAccess.fullGym    => Icons.apartment_rounded,
    EquipmentAccess.homeGym    => Icons.home_rounded,
    EquipmentAccess.dumbbells  => Icons.fitness_center_rounded,
    EquipmentAccess.bodyweight => Icons.accessibility_new_rounded,
  };
}

enum Gender { male, female }

class OnboardingData {
  const OnboardingData({
    this.goal,
    this.experience,
    this.daysPerWeek,
    this.equipment,
    this.gender,
    this.age,
    this.weightKg,
    this.heightCm,
  });

  final TrainingGoal?    goal;
  final ExperienceLevel? experience;
  final int?             daysPerWeek;
  final EquipmentAccess? equipment;
  final Gender?          gender;
  final int?             age;
  final double?          weightKg;
  final double?          heightCm;

  OnboardingData copyWith({
    TrainingGoal?    goal,
    ExperienceLevel? experience,
    int?             daysPerWeek,
    EquipmentAccess? equipment,
    Gender?          gender,
    int?             age,
    double?          weightKg,
    double?          heightCm,
  }) => OnboardingData(
    goal:        goal        ?? this.goal,
    experience:  experience  ?? this.experience,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    equipment:   equipment   ?? this.equipment,
    gender:      gender      ?? this.gender,
    age:         age         ?? this.age,
    weightKg:    weightKg    ?? this.weightKg,
    heightCm:    heightCm    ?? this.heightCm,
  );

  bool get isComplete =>
      goal != null &&
      experience != null &&
      daysPerWeek != null &&
      equipment != null;
}
