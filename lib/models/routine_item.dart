import '../core/constants/app_constants.dart';
import '../core/utils/date_time_util.dart';

class RoutineItem {
  final String id;
  final String title;
  final String dosage;
  final RoutineType type;
  final DaySector sector;
  final int scheduledHour;
  final int scheduledMinute;
  final FoodRule foodRule;
  final bool requiresFullGlassWater;
  final int? totalSupply;
  final int? currentInventory;
  final int dailyPillCount;
  final int refillThresholdDays;
  final bool isCritical;
  final List<DateTime> completedLogs;
  final int streakCount;

  RoutineItem({
    required this.id,
    required this.title,
    required this.dosage,
    this.type = RoutineType.medication,
    required this.sector,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.foodRule = FoodRule.none,
    this.requiresFullGlassWater = false,
    this.totalSupply,
    this.currentInventory,
    this.dailyPillCount = 1,
    this.refillThresholdDays = AppConstants.lowSupplyAlertThresholdDays,
    this.isCritical = false,
    List<DateTime>? completedLogs,
    this.streakCount = 0,
  }) : completedLogs = completedLogs ?? [];

  /// Checks if this item has already been checked off today
  bool get isCompletedToday {
    final now = DateTime.now();
    return completedLogs.any((log) => DateTimeUtil.isSameDay(log, now));
  }

  /// Calculates estimated days of supply remaining
  int? get daysOfSupplyRemaining {
    if (currentInventory == null || dailyPillCount <= 0) return null;
    return (currentInventory! / dailyPillCount).floor();
  }

  /// Flags if a refill warning should trigger
  bool get isRefillNeeded {
    final days = daysOfSupplyRemaining;
    if (days == null) return false;
    return days <= refillThresholdDays;
  }

  /// Returns a copy of the item marked as completed today
  RoutineItem markCompleted([DateTime? logTime]) {
    final now = logTime ?? DateTime.now();
    final updatedLogs = List<DateTime>.from(completedLogs)..add(now);
    final updatedInventory = (currentInventory != null && currentInventory! > 0)
        ? currentInventory! - dailyPillCount
        : currentInventory;

    return copyWith(
      completedLogs: updatedLogs,
      currentInventory: updatedInventory,
      streakCount: streakCount + 1,
    );
  }

  RoutineItem copyWith({
    String? id,
    String? title,
    String? dosage,
    RoutineType? type,
    DaySector? sector,
    int? scheduledHour,
    int? scheduledMinute,
    FoodRule? foodRule,
    bool? requiresFullGlassWater,
    int? totalSupply,
    int? currentInventory,
    int? dailyPillCount,
    int? refillThresholdDays,
    bool? isCritical,
    List<DateTime>? completedLogs,
    int? streakCount,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      sector: sector ?? this.sector,
      scheduledHour: scheduledHour ?? this.scheduledHour,
      scheduledMinute: scheduledMinute ?? this.scheduledMinute,
      foodRule: foodRule ?? this.foodRule,
      requiresFullGlassWater:
          requiresFullGlassWater ?? this.requiresFullGlassWater,
      totalSupply: totalSupply ?? this.totalSupply,
      currentInventory: currentInventory ?? this.currentInventory,
      dailyPillCount: dailyPillCount ?? this.dailyPillCount,
      refillThresholdDays: refillThresholdDays ?? this.refillThresholdDays,
      isCritical: isCritical ?? this.isCritical,
      completedLogs: completedLogs ?? this.completedLogs,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dosage': dosage,
      'type': type.name,
      'sector': sector.name,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'foodRule': foodRule.name,
      'requiresFullGlassWater': requiresFullGlassWater,
      'totalSupply': totalSupply,
      'currentInventory': currentInventory,
      'dailyPillCount': dailyPillCount,
      'refillThresholdDays': refillThresholdDays,
      'isCritical': isCritical,
      'completedLogs':
          completedLogs.map((e) => e.toIso8601String()).toList(),
      'streakCount': streakCount,
    };
  }

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dosage: json['dosage'] as String,
      type: RoutineType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoutineType.medication,
      ),
      sector: DaySector.values.firstWhere(
        (e) => e.name == json['sector'],
        orElse: () => DaySector.morning,
      ),
      scheduledHour: json['scheduledHour'] as int? ?? 8,
      scheduledMinute: json['scheduledMinute'] as int? ?? 0,
      foodRule: FoodRule.values.firstWhere(
        (e) => e.name == json['foodRule'],
        orElse: () => FoodRule.none,
      ),
      requiresFullGlassWater:
          json['requiresFullGlassWater'] as bool? ?? false,
      totalSupply: json['totalSupply'] as int?,
      currentInventory: json['currentInventory'] as int?,
      dailyPillCount: json['dailyPillCount'] as int? ?? 1,
      refillThresholdDays: json['refillThresholdDays'] as int? ??
          AppConstants.lowSupplyAlertThresholdDays,
      isCritical: json['isCritical'] as bool? ?? false,
      completedLogs: (json['completedLogs'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      streakCount: json['streakCount'] as int? ?? 0,
    );
  }
}
