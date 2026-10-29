class MovementState {
  final int todaySteps;
  final int hourlySittingMinutes;
  final DateTime lastMovementTime;
  final int stretchesCompleted;
  final int dailyMovementGoal;

  MovementState({
    this.todaySteps = 0,
    this.hourlySittingMinutes = 0,
    DateTime? lastMovementTime,
    this.stretchesCompleted = 0,
    this.dailyMovementGoal = 8, // 8 hourly micro-breaks
  }) : lastMovementTime = lastMovementTime ?? DateTime.now();

  /// Whether user has exceeded 50 minutes of sitting
  bool get isSedentaryAlertDue => hourlySittingMinutes >= 50;

  /// Progress ratio towards daily micro-breaks
  double get progressPercentage {
    if (dailyMovementGoal <= 0) return 0.0;
    final ratio = stretchesCompleted / dailyMovementGoal;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  /// Records a micro-break (e.g. 2-minute stretch or walk)
  MovementState recordStretch([DateTime? time]) {
    final now = time ?? DateTime.now();
    return MovementState(
      todaySteps: todaySteps + 200, // estimated micro-steps
      hourlySittingMinutes: 0, // reset sitting timer
      lastMovementTime: now,
      stretchesCompleted: stretchesCompleted + 1,
      dailyMovementGoal: dailyMovementGoal,
    );
  }

  /// Adds passive step sensor counts
  MovementState addSteps(int steps, [DateTime? time]) {
    final now = time ?? DateTime.now();
    return MovementState(
      todaySteps: todaySteps + steps,
      hourlySittingMinutes: steps > 100 ? 0 : hourlySittingMinutes,
      lastMovementTime: steps > 100 ? now : lastMovementTime,
      stretchesCompleted: stretchesCompleted,
      dailyMovementGoal: dailyMovementGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySteps': todaySteps,
      'hourlySittingMinutes': hourlySittingMinutes,
      'lastMovementTime': lastMovementTime.toIso8601String(),
      'stretchesCompleted': stretchesCompleted,
      'dailyMovementGoal': dailyMovementGoal,
    };
  }

  factory MovementState.fromJson(Map<String, dynamic> json) {
    return MovementState(
      todaySteps: json['todaySteps'] as int? ?? 0,
      hourlySittingMinutes: json['hourlySittingMinutes'] as int? ?? 0,
      lastMovementTime: json['lastMovementTime'] != null
          ? DateTime.parse(json['lastMovementTime'] as String)
          : DateTime.now(),
      stretchesCompleted: json['stretchesCompleted'] as int? ?? 0,
      dailyMovementGoal: json['dailyMovementGoal'] as int? ?? 8,
    );
  }
}
