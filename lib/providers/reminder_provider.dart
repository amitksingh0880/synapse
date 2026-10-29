import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptics_util.dart';
import '../models/smart_reminder.dart';
import '../services/storage_service.dart';
import 'routine_provider.dart';

class ReminderNotifier extends StateNotifier<List<SmartReminder>> {
  final StorageService _storage;

  ReminderNotifier(this._storage) : super([]) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    final loaded = await _storage.loadReminders();
    state = loaded;
  }

  Future<void> addReminder(SmartReminder reminder) async {
    HapticsUtil.lightTick();
    state = [...state, reminder];
    await _storage.saveReminders(state);
  }

  Future<void> toggleCompleted(String id) async {
    HapticsUtil.mediumConfirm();
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(isCompleted: !r.isCompleted);
      }
      return r;
    }).toList();
    await _storage.saveReminders(state);
  }

  Future<void> deleteReminder(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _storage.saveReminders(state);
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<SmartReminder>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ReminderNotifier(storage);
});
