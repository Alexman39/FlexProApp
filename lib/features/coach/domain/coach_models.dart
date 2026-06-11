enum CoachPostType { tip, motivation, programUpdate, nutrition }

class CoachPost {
  const CoachPost({
    required this.id,
    required this.message,
    required this.type,
    required this.date,
  });

  final String id;
  final String message;
  final CoachPostType type;
  final DateTime date;
}

class CoachFeedback {
  const CoachFeedback({
    required this.id,
    required this.message,
    required this.date,
    required this.sessionRef,
  });

  final String id;
  final String message;
  final DateTime date;
  final String sessionRef;
}
