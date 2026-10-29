import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptics_util.dart';
import '../models/movement_state.dart';
import '../services/storage_service.dart';
import 'routine_provider.dart';

class MovementNotifier extends StateNotifier<MovementState> {
  final StorageService _storage;

  MovementNotifier(this._storage) : super(MovementState()) {
    loadMovement();
  }

  Future<void> loadMovement() async {
    final loaded = await _storage.loadMovementState();
    state = loaded;
  }

  Future<void> recordMicroBreak() async {
    HapticsUtil.mediumConfirm();
    state = state.recordStretch();
    await _storage.saveMovementState(state);
  }

  Future<void> addSteps(int steps) async {
    state = state.addSteps(steps);
    await _storage.saveMovementState(state);
  }
}

final movementProvider =
    StateNotifierProvider<MovementNotifier, MovementState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MovementNotifier(storage);
});
