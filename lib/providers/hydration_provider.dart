import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptics_util.dart';
import '../models/hydration_state.dart';
import '../services/storage_service.dart';
import 'routine_provider.dart';

class HydrationNotifier extends StateNotifier<HydrationState> {
  final StorageService _storage;

  HydrationNotifier(this._storage) : super(HydrationState()) {
    loadHydration();
  }

  Future<void> loadHydration() async {
    final stateLoaded = await _storage.loadHydrationState();
    state = stateLoaded;
  }

  Future<void> addWater([int ml = 250]) async {
    HapticsUtil.lightTick();
    state = state.addIntake(ml);
    await _storage.saveHydrationState(state);

    if (state.isGoalReached) {
      HapticsUtil.celebration();
    }
  }

  Future<void> setDailyGoal(int targetMl) async {
    state = HydrationState(
      targetMl: targetMl,
      consumedMl: state.consumedMl,
      defaultGlassSizeMl: state.defaultGlassSizeMl,
      logTimestamps: state.logTimestamps,
      lastLogTime: state.lastLogTime,
    );
    await _storage.saveHydrationState(state);
  }
}

final hydrationProvider =
    StateNotifierProvider<HydrationNotifier, HydrationState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HydrationNotifier(storage);
});
