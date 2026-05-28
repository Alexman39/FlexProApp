import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/onboarding_models.dart';

class OnboardingNotifier extends Notifier<OnboardingData> {
  @override
  OnboardingData build() => const OnboardingData();

  void setGoal(TrainingGoal goal) =>
      state = state.copyWith(goal: goal);

  void setExperience(ExperienceLevel exp) =>
      state = state.copyWith(experience: exp);

  void setDays(int days) =>
      state = state.copyWith(daysPerWeek: days);

  void setEquipment(EquipmentAccess equip) =>
      state = state.copyWith(equipment: equip);

  void setGender(Gender gender) =>
      state = state.copyWith(gender: gender);

  void setStats({int? age, double? weightKg, double? heightCm}) =>
      state = state.copyWith(age: age, weightKg: weightKg, heightCm: heightCm);

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (state.goal != null) {
      await prefs.setString('goal', state.goal!.name);
    }
    if (state.experience != null) {
      await prefs.setString('experience', state.experience!.name);
    }
    if (state.daysPerWeek != null) {
      await prefs.setInt('days_per_week', state.daysPerWeek!);
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingData>(
  OnboardingNotifier.new,
);

// ── Step index provider ──────────────────────────────────
class OnboardingStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state = (state + 1).clamp(0, 4);
  void back() => state = (state - 1).clamp(0, 4);
  void reset() => state = 0;
}

final onboardingStepProvider =
    NotifierProvider<OnboardingStepNotifier, int>(
  OnboardingStepNotifier.new,
);
