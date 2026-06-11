import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/coach_data.dart';
import '../data/firestore_coach_repository.dart';
import '../domain/coach_models.dart';

final coachPostsProvider = StreamProvider<List<CoachPost>>((ref) {
  final repo = ref.watch(firestoreCoachRepoProvider);
  if (repo == null) return Stream.value(mockCoachPosts);
  return repo.watchCoachPosts();
});

final coachFeedbackProvider = StreamProvider<List<CoachFeedback>>((ref) {
  final repo = ref.watch(firestoreCoachRepoProvider);
  if (repo == null) return Stream.value(mockCoachFeedback);
  return repo.watchCoachFeedback();
});

// Streams the coach's pinned note from Firestore; falls back to the most
// recent mock post when Firebase is unavailable (Linux dev / unauthenticated).
final coachNoteProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(firestoreCoachRepoProvider);
  if (repo == null) return Stream.value(mockCoachPosts.first.message);
  return repo.watchCoachNote();
});

// ── Weekly check-in ────────────────────────────────────────

enum CheckInStatus { idle, loading, sent, error }

class CheckInNotifier extends AutoDisposeNotifier<CheckInStatus> {
  @override
  CheckInStatus build() => CheckInStatus.idle;

  Future<void> submit({required int rating, required String note}) async {
    state = CheckInStatus.loading;
    final repo = ref.read(firestoreCoachRepoProvider);
    try {
      if (repo != null) {
        await repo.saveCheckIn(rating: rating, note: note);
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }
      state = CheckInStatus.sent;
    } catch (_) {
      state = CheckInStatus.error;
    }
  }
}

final checkInProvider =
    AutoDisposeNotifierProvider<CheckInNotifier, CheckInStatus>(
  CheckInNotifier.new,
);

// ── Coach feedback request ─────────────────────────────────────

enum FeedbackRequestStatus { idle, loading, sent, error }

class FeedbackRequestNotifier
    extends AutoDisposeNotifier<FeedbackRequestStatus> {
  @override
  FeedbackRequestStatus build() => FeedbackRequestStatus.idle;

  Future<void> request(String logId) async {
    state = FeedbackRequestStatus.loading;
    final repo = ref.read(firestoreCoachRepoProvider);
    try {
      if (repo != null) {
        await repo.requestFeedback(logId);
      } else {
        // No Firebase (Linux dev) — simulate round-trip
        await Future.delayed(const Duration(milliseconds: 600));
      }
      state = FeedbackRequestStatus.sent;
    } catch (_) {
      state = FeedbackRequestStatus.error;
    }
  }
}

final feedbackRequestProvider = AutoDisposeNotifierProvider<
    FeedbackRequestNotifier, FeedbackRequestStatus>(
  FeedbackRequestNotifier.new,
);
