import 'package:cloud_firestore/cloud_firestore.dart';

class RecoveryEntry {
  const RecoveryEntry({
    required this.sleep,
    required this.energy,
    required this.soreness,
  });

  final int sleep;
  final int energy;
  final int soreness;
}

class ReadinessRepository {
  ReadinessRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('readiness');

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<RecoveryEntry?> getToday() async {
    final snap = await _col.doc(_todayKey()).get();
    if (!snap.exists) return null;
    final d = snap.data()!;
    return RecoveryEntry(
      sleep: d['sleep'] as int? ?? 0,
      energy: d['energy'] as int? ?? 0,
      soreness: d['soreness'] as int? ?? 0,
    );
  }

  Future<void> saveToday(RecoveryEntry entry) async {
    await _col.doc(_todayKey()).set({
      'sleep': entry.sleep,
      'energy': entry.energy,
      'soreness': entry.soreness,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
}
