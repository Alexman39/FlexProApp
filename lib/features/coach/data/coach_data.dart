import '../domain/coach_models.dart';

final List<CoachPost> mockCoachPosts = [
  CoachPost(
    id: 'p1',
    message:
        'Great work this week. Push your squat intensity up by 5% next session — you have the strength for it. Trust the progression.',
    type: CoachPostType.programUpdate,
    date: DateTime(2026, 6, 9),
  ),
  CoachPost(
    id: 'p2',
    message:
        'Nutrition reminder: aim for 2g of protein per kg of bodyweight daily. Prioritize whole food sources post-workout — lean meats, eggs, Greek yogurt.',
    type: CoachPostType.nutrition,
    date: DateTime(2026, 6, 7),
  ),
  CoachPost(
    id: 'p3',
    message:
        'Sleep is where adaptation happens. If you are consistently under 7 hours, your recovery and progress will stall. Prioritize it as seriously as you prioritize training.',
    type: CoachPostType.tip,
    date: DateTime(2026, 6, 5),
  ),
  CoachPost(
    id: 'p4',
    message:
        'Halfway through Phase 2. You are building a serious base. Results compound over weeks, not days — stay consistent and the progress will speak for itself.',
    type: CoachPostType.motivation,
    date: DateTime(2026, 6, 2),
  ),
];

final List<CoachFeedback> mockCoachFeedback = [
  CoachFeedback(
    id: 'f1',
    message:
        'Your bench form has improved significantly. Keep your shoulder blades retracted throughout the entire set — you lost it on the last 2 reps. Next session, add 2.5 kg.',
    date: DateTime(2026, 6, 8),
    sessionRef: 'Week 3 · Push Day',
  ),
  CoachFeedback(
    id: 'f2',
    message:
        'Solid effort on the deadlifts. Watch your lower back rounding on heavy sets — reset between reps if needed. Quality over quantity every time.',
    date: DateTime(2026, 6, 4),
    sessionRef: 'Week 3 · Pull Day',
  ),
  CoachFeedback(
    id: 'f3',
    message:
        'Excellent conditioning this week. Your resting heart rate data shows clear adaptation. The discipline you are showing is exactly what produces long-term results.',
    date: DateTime(2026, 5, 29),
    sessionRef: 'Week 2 · Full Body',
  ),
];
