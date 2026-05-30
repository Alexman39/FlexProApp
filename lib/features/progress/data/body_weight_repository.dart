import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/firebase_availability.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/body_weight_model.dart';

// ── Hive ──────────────────────────────────────────────────

class _LocalBodyWeightRepo {
  static const _box = 'body_weight';

  List<BodyWeightEntry> getAll() {
    final box = Hive.box<String>(_box);
    return box.values.map((s) {
      try {
        return BodyWeightEntry.fromJson(
            jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<BodyWeightEntry>().toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> save(BodyWeightEntry e) async =>
      Hive.box<String>(_box).put(e.dateKey, jsonEncode(e.toJson()));
}

// ── Firestore ─────────────────────────────────────────────

class _FirestoreBodyWeightRepo {
  _FirestoreBodyWeightRepo(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('bodyWeight');

  Stream<List<BodyWeightEntry>> watch() => _col
      .orderBy('date')
      .snapshots()
      .map((s) => s.docs
          .map((d) => BodyWeightEntry.fromJson(d.data()))
          .toList());

  Future<void> save(BodyWeightEntry e) =>
      _col.doc(e.dateKey).set(e.toJson());
}

// ── Providers ─────────────────────────────────────────────

final _localBodyWeightRepo =
    Provider<_LocalBodyWeightRepo>((_) => _LocalBodyWeightRepo());

final _firestoreBodyWeightRepoProvider =
    Provider<_FirestoreBodyWeightRepo?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = ref.read(firestoreProvider);
  if (db == null) return null;
  return _FirestoreBodyWeightRepo(db, uid);
});

class BodyWeightNotifier extends AsyncNotifier<List<BodyWeightEntry>> {
  @override
  Future<List<BodyWeightEntry>> build() async {
    final firestoreRepo = ref.watch(_firestoreBodyWeightRepoProvider);
    if (firestoreRepo != null) {
      return ref.watch(
        _bodyWeightStreamProvider.select((v) => v.valueOrNull ?? []),
      );
    }
    return ref.read(_localBodyWeightRepo).getAll();
  }

  Future<void> logWeight(double weightKg) async {
    final entry = BodyWeightEntry(
      date: DateTime.now(),
      weightKg: weightKg,
    );
    final firestoreRepo = ref.read(_firestoreBodyWeightRepoProvider);
    if (firestoreRepo != null) {
      await firestoreRepo.save(entry);
    } else {
      await ref.read(_localBodyWeightRepo).save(entry);
      final updated = ref.read(_localBodyWeightRepo).getAll();
      state = AsyncData(updated);
    }
  }
}

final _bodyWeightStreamProvider = StreamProvider<List<BodyWeightEntry>>((ref) {
  final repo = ref.watch(_firestoreBodyWeightRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watch();
});

final bodyWeightProvider =
    AsyncNotifierProvider<BodyWeightNotifier, List<BodyWeightEntry>>(
        BodyWeightNotifier.new);
