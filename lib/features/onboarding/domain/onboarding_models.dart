// ── Domain models for onboarding questionnaire ──────────

enum TrainingGoal {
  hypertrophy('Hypertrophy',    'Build muscle mass and size',          '💪'),
  strength   ('Strength',       'Maximize your lifts',                  '🏋️'),
  fatLoss    ('Fat Loss',       'Lean out while preserving muscle',     '🔥'),
  recomp     ('Recomposition',  'Build muscle and lose fat simultaneously', '⚖️'),
  general    ('General Fitness','Look, feel, and perform better',       '🎯');

  const TrainingGoal(this.label, this.description, this.emoji);
  final String label;
  final String description;
  final String emoji;
}

enum ExperienceLevel {
  beginner    ('Beginner',     'Less than 1 year of consistent training', '🌱'),
  intermediate('Intermediate', '1–3 years of consistent training',         '📈'),
  advanced    ('Advanced',     '3+ years, know your body well',            '🏆');

  const ExperienceLevel(this.label, this.description, this.emoji);
  final String label;
  final String description;
  final String emoji;
}

enum EquipmentAccess {
  fullGym    ('Full Gym',       'All equipment, cables, machines, free weights', '🏢'),
  homeGym    ('Home Gym',       'Barbells, dumbbells, some machines',            '🏠'),
  dumbbells  ('Dumbbells Only', 'Just dumbbells and a bench',                    '🔵'),
  bodyweight ('Bodyweight',     'No equipment needed',                           '🤸');

  const EquipmentAccess(this.label, this.description, this.emoji);
  final String label;
  final String description;
  final String emoji;
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
