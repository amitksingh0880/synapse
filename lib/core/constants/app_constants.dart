enum DaySector {
  morning,
  afternoon,
  evening,
  night,
}

enum RoutineType {
  medication,
  movement,
  habit,
}

enum FoodRule {
  withFood,
  emptyStomach,
  afterMealGap,
  none,
}

enum MemoryCategory {
  location,
  credential,
  person,
  fact,
  general,
}

enum ReminderPriority {
  gentle,
  standard,
  critical,
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Synapse';
  static const String appTagline = 'Ambient Routine & Memory Engine';

  // Hydration Defaults
  static const int defaultDailyHydrationTargetMl = 2500;
  static const int defaultGlassIncrementMl = 250;

  // Sedentary Threshold
  static const int sedentaryInactivityThresholdMinutes = 50;

  // Medicine Inventory
  static const int lowSupplyAlertThresholdDays = 5;

  // SharedPreferences Keys
  static const String storageKeyRoutines = 'synapse_routines_v1';
  static const String storageKeyHydration = 'synapse_hydration_v1';
  static const String storageKeyMovement = 'synapse_movement_v1';
  static const String storageKeyMemories = 'synapse_memories_v1';
  static const String storageKeyReminders = 'synapse_reminders_v1';
}
