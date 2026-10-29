import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/routine_item.dart';
import '../models/hydration_state.dart';
import '../models/movement_state.dart';
import '../models/memory_item.dart';
import '../models/smart_reminder.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ---------------------------------------------------------------------------
  // Routine & Medications
  // ---------------------------------------------------------------------------

  Future<List<RoutineItem>> loadRoutines() async {
    final raw = _prefs.getString(AppConstants.storageKeyRoutines);
    if (raw == null || raw.isEmpty) {
      return _seedDefaultRoutines();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => RoutineItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seedDefaultRoutines();
    }
  }

  Future<void> saveRoutines(List<RoutineItem> routines) async {
    final raw = jsonEncode(routines.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.storageKeyRoutines, raw);
  }

  // ---------------------------------------------------------------------------
  // Hydration Engine
  // ---------------------------------------------------------------------------

  Future<HydrationState> loadHydrationState() async {
    final raw = _prefs.getString(AppConstants.storageKeyHydration);
    if (raw == null || raw.isEmpty) {
      return HydrationState();
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return HydrationState.fromJson(decoded);
    } catch (_) {
      return HydrationState();
    }
  }

  Future<void> saveHydrationState(HydrationState state) async {
    final raw = jsonEncode(state.toJson());
    await _prefs.setString(AppConstants.storageKeyHydration, raw);
  }

  // ---------------------------------------------------------------------------
  // Movement & Sedentary State
  // ---------------------------------------------------------------------------

  Future<MovementState> loadMovementState() async {
    final raw = _prefs.getString(AppConstants.storageKeyMovement);
    if (raw == null || raw.isEmpty) {
      return MovementState();
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return MovementState.fromJson(decoded);
    } catch (_) {
      return MovementState();
    }
  }

  Future<void> saveMovementState(MovementState state) async {
    final raw = jsonEncode(state.toJson());
    await _prefs.setString(AppConstants.storageKeyMovement, raw);
  }

  // ---------------------------------------------------------------------------
  // Memory Vault
  // ---------------------------------------------------------------------------

  Future<List<MemoryItem>> loadMemories() async {
    final raw = _prefs.getString(AppConstants.storageKeyMemories);
    if (raw == null || raw.isEmpty) {
      return _seedDefaultMemories();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seedDefaultMemories();
    }
  }

  Future<void> saveMemories(List<MemoryItem> memories) async {
    final raw = jsonEncode(memories.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.storageKeyMemories, raw);
  }

  // ---------------------------------------------------------------------------
  // Smart Reminders
  // ---------------------------------------------------------------------------

  Future<List<SmartReminder>> loadReminders() async {
    final raw = _prefs.getString(AppConstants.storageKeyReminders);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => SmartReminder.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReminders(List<SmartReminder> reminders) async {
    final raw = jsonEncode(reminders.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.storageKeyReminders, raw);
  }

  // ---------------------------------------------------------------------------
  // Seeders (Delightful default onboarding data)
  // ---------------------------------------------------------------------------

  List<RoutineItem> _seedDefaultRoutines() {
    return [
      RoutineItem(
        id: 'seed_med_1',
        title: 'Metformin',
        dosage: '500mg - 2 pills',
        type: RoutineType.medication,
        sector: DaySector.morning,
        scheduledHour: 8,
        scheduledMinute: 30,
        foodRule: FoodRule.withFood,
        requiresFullGlassWater: true,
        totalSupply: 60,
        currentInventory: 14,
        dailyPillCount: 2,
        isCritical: true,
        streakCount: 6,
      ),
      RoutineItem(
        id: 'seed_med_2',
        title: 'Vitamin D3 & K2',
        dosage: '1 capsule',
        type: RoutineType.medication,
        sector: DaySector.morning,
        scheduledHour: 9,
        scheduledMinute: 0,
        foodRule: FoodRule.withFood,
        requiresFullGlassWater: true,
        totalSupply: 90,
        currentInventory: 72,
        dailyPillCount: 1,
        streakCount: 12,
      ),
      RoutineItem(
        id: 'seed_med_3',
        title: 'Magnesium Glycinate',
        dosage: '400mg - 2 capsules',
        type: RoutineType.medication,
        sector: DaySector.evening,
        scheduledHour: 21,
        scheduledMinute: 30,
        foodRule: FoodRule.afterMealGap,
        requiresFullGlassWater: true,
        totalSupply: 60,
        currentInventory: 8, // Triggers low supply refill alert!
        dailyPillCount: 2,
        streakCount: 9,
      ),
      RoutineItem(
        id: 'seed_hab_1',
        title: 'Midday Spinal Decompression Stretch',
        dosage: '3 minutes',
        type: RoutineType.movement,
        sector: DaySector.afternoon,
        scheduledHour: 14,
        scheduledMinute: 0,
        streakCount: 4,
      ),
    ];
  }

  List<MemoryItem> _seedDefaultMemories() {
    return [
      MemoryItem(
        id: 'seed_mem_1',
        keyQuery: 'parking spot level 2',
        content: 'Basement Level 2, Pillar B14 (adjacent to West Elevator)',
        category: MemoryCategory.location,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        tags: ['parking', 'car', 'mall', 'basement'],
      ),
      MemoryItem(
        id: 'seed_mem_2',
        keyQuery: 'locker code gym',
        content: 'Cabinet #48, Combination: 8492',
        category: MemoryCategory.credential,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        tags: ['locker', 'code', 'gym', 'combination'],
      ),
      MemoryItem(
        id: 'seed_mem_3',
        keyQuery: 'rahul shoe size birthday',
        content: 'US 10.5 (EU 44.5), prefers neutral running shoes',
        category: MemoryCategory.person,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        tags: ['rahul', 'gift', 'shoes', 'birthday'],
      ),
    ];
  }
}
