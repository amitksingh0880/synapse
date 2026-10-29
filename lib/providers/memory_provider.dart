import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptics_util.dart';
import '../models/memory_item.dart';
import '../services/storage_service.dart';
import 'routine_provider.dart';

class MemoryNotifier extends StateNotifier<List<MemoryItem>> {
  final StorageService _storage;

  MemoryNotifier(this._storage) : super([]) {
    loadMemories();
  }

  Future<void> loadMemories() async {
    final loaded = await _storage.loadMemories();
    state = loaded;
  }

  Future<void> addMemory(MemoryItem item) async {
    HapticsUtil.lightTick();
    state = [item, ...state];
    await _storage.saveMemories(state);
  }

  Future<void> deleteMemory(String id) async {
    state = state.where((m) => m.id != id).toList();
    await _storage.saveMemories(state);
  }

  /// Instant fuzzy search query
  List<MemoryItem> query(String text) {
    if (text.isEmpty) return state;
    return state.where((m) => m.matchesQuery(text)).toList();
  }
}

final memoryProvider =
    StateNotifierProvider<MemoryNotifier, List<MemoryItem>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MemoryNotifier(storage);
});
