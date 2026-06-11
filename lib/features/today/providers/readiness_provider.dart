import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_availability.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/readiness_repository.dart';

export '../data/readiness_repository.dart' show RecoveryEntry;

final readinessRepoProvider = Provider<ReadinessRepository?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  final db = ref.read(firestoreProvider);
  if (db == null) return null;
  return ReadinessRepository(db, uid);
});

class ReadinessNotifier extends AsyncNotifier<RecoveryEntry?> {
  @override
  Future<RecoveryEntry?> build() async {
    final repo = ref.watch(readinessRepoProvider);
    if (repo == null) return null;
    return repo.getToday();
  }

  Future<void> save(RecoveryEntry entry) async {
    final repo = ref.read(readinessRepoProvider);
    if (repo == null) return;
    state = AsyncData(entry);
    await repo.saveToday(entry);
  }
}

final readinessProvider =
    AsyncNotifierProvider<ReadinessNotifier, RecoveryEntry?>(
        ReadinessNotifier.new);
