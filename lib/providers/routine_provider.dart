import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/haptics_util.dart';
import '../models/routine_item.dart';
import '../services/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

class RoutineNotifier extends StateNotifier<List<RoutineItem>> {
  final StorageService _storage;

  RoutineNotifier(this._storage) : super([]) {
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    final routines = await _storage.loadRoutines();
    state = routines;
  }

  Future<void> toggleCompletion(String id) async {
    state = state.map((item) {
      if (item.id == id) {
        if (item.isCompletedToday) {
          // Uncheck
          final updatedLogs = List.of(item.completedLogs)
            ..removeWhere((d) =>
                d.year == DateTime.now().year &&
                d.month == DateTime.now().month &&
                d.day == DateTime.now().day);
          return item.copyWith(completedLogs: updatedLogs);
        } else {
          // Check
          HapticsUtil.mediumConfirm();
          return item.markCompleted();
        }
      }
      return item;
    }).toList();

    await _storage.saveRoutines(state);
  }

  Future<void> addRoutine(RoutineItem item) async {
    state = [...state, item];
    HapticsUtil.lightTick();
    await _storage.saveRoutines(state);
  }

  /// Calculates percentage of today's completed items
  double get todayCompliancePercentage {
    if (state.isEmpty) return 1.0;
    final completed = state.where((r) => r.isCompletedToday).length;
    return completed / state.length;
  }

  /// Filters routines active for a specific DaySector
  List<RoutineItem> routinesForSector(DaySector sector) {
    return state.where((r) => r.sector == sector).toList();
  }
}

final routineProvider =
    StateNotifierProvider<RoutineNotifier, List<RoutineItem>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RoutineNotifier(storage);
});
