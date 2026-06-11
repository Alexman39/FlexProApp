import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_availability.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/coach_models.dart';

class FirestoreCoachRepository {
  FirestoreCoachRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  Stream<String?> watchCoachNote() =>
      _firestore.collection('users').doc(_uid).snapshots().map(
            (snap) => snap.data()?['coachNote'] as String?,
          );

  Stream<List<CoachPost>> watchCoachPosts() =>
      _firestore
          .collection('coach')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                final d = doc.data();
                return CoachPost(
                  id: doc.id,
                  message: d['message'] as String,
                  type: CoachPostType.values.firstWhere(
                    (e) => e.name == (d['type'] as String? ?? 'tip'),
                    orElse: () => CoachPostType.tip,
                  ),
                  date: (d['date'] as Timestamp).toDate(),
                );
              }).toList());

  Stream<List<CoachFeedback>> watchCoachFeedback() =>
      _firestore
          .collection('users')
          .doc(_uid)
          .collection('coachFeedback')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                final d = doc.data();
                return CoachFeedback(
                  id: doc.id,
                  message: d['message'] as String,
                  date: (d['date'] as Timestamp).toDate(),
                  sessionRef: d['sessionRef'] as String? ?? '',
                );
              }).toList());

  Future<void> saveCheckIn({required int rating, required String note}) =>
      _firestore
          .collection('users')
          .doc(_uid)
          .collection('checkIns')
          .add({
        'rating': rating,
        'note': note,
        'submittedAt': FieldValue.serverTimestamp(),
      });

  Future<void> requestFeedback(String logId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('feedbackRequests')
        .doc(logId)
        .set({
      'logId': logId,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}

final firestoreCoachRepoProvider = Provider<FirestoreCoachRepository?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = ref.read(firestoreProvider);
  if (db == null) return null;
  return FirestoreCoachRepository(db, uid);
});
