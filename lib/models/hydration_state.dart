import '../core/constants/app_constants.dart';
import '../core/utils/date_time_util.dart';

class HydrationState {
  final int targetMl;
  final int consumedMl;
  final int defaultGlassSizeMl;
  final List<DateTime> logTimestamps;
  final DateTime lastLogTime;

  HydrationState({
    this.targetMl = AppConstants.defaultDailyHydrationTargetMl,
    this.consumedMl = 0,
    this.defaultGlassSizeMl = AppConstants.defaultGlassIncrementMl,
    List<DateTime>? logTimestamps,
    DateTime? lastLogTime,
  })  : logTimestamps = logTimestamps ?? [],
        lastLogTime = lastLogTime ?? DateTime.now();

  /// Progress ratio clamped between 0.0 and 1.0
  double get progressPercentage {
    if (targetMl <= 0) return 0.0;
    final ratio = consumedMl / targetMl;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  /// Alias for compliance / progress percentage
  double get compliancePercentage => progressPercentage;

  /// Whether user hit their daily water target
  bool get isGoalReached => consumedMl >= targetMl;

  /// Approximate number of standard glasses consumed
  int get glassesConsumed {
    if (defaultGlassSizeMl <= 0) return 0;
    return (consumedMl / defaultGlassSizeMl).floor();
  }

  /// Total standard glasses needed to reach target
  int get totalGlassesGoal {
    if (defaultGlassSizeMl <= 0) return 0;
    return (targetMl / defaultGlassSizeMl).ceil();
  }

  /// Adds water intake and appends a timestamp
  HydrationState addIntake(int ml, [DateTime? time]) {
    final now = time ?? DateTime.now();
    final updatedLogs = List<DateTime>.from(logTimestamps)..add(now);

    return HydrationState(
      targetMl: targetMl,
      consumedMl: consumedMl + ml,
      defaultGlassSizeMl: defaultGlassSizeMl,
      logTimestamps: updatedLogs,
      lastLogTime: now,
    );
  }

  /// Resets daily hydration state (for new calendar days)
  HydrationState resetForNewDay([DateTime? time]) {
    final now = time ?? DateTime.now();
    return HydrationState(
      targetMl: targetMl,
      consumedMl: 0,
      defaultGlassSizeMl: defaultGlassSizeMl,
      logTimestamps: [],
      lastLogTime: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetMl': targetMl,
      'consumedMl': consumedMl,
      'defaultGlassSizeMl': defaultGlassSizeMl,
      'logTimestamps':
          logTimestamps.map((e) => e.toIso8601String()).toList(),
      'lastLogTime': lastLogTime.toIso8601String(),
    };
  }

  factory HydrationState.fromJson(Map<String, dynamic> json) {
    return HydrationState(
      targetMl: json['targetMl'] as int? ??
          AppConstants.defaultDailyHydrationTargetMl,
      consumedMl: json['consumedMl'] as int? ?? 0,
      defaultGlassSizeMl: json['defaultGlassSizeMl'] as int? ??
          AppConstants.defaultGlassIncrementMl,
      logTimestamps: (json['logTimestamps'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      lastLogTime: json['lastLogTime'] != null
          ? DateTime.parse(json['lastLogTime'] as String)
          : DateTime.now(),
    );
  }
}
