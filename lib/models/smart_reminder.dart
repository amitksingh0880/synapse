import '../core/constants/app_constants.dart';

class SmartReminder {
  final String id;
  final String prompt;
  final DateTime triggerAt;
  final int? intervalCountdownMinutes;
  final ReminderPriority priority;
  final bool isCompleted;

  SmartReminder({
    required this.id,
    required this.prompt,
    required this.triggerAt,
    this.intervalCountdownMinutes,
    this.priority = ReminderPriority.standard,
    this.isCompleted = false,
  });

  /// True if the reminder scheduled trigger has passed
  bool get isDue => DateTime.now().isAfter(triggerAt);

  /// Remaining minutes for spaced dosing / Live Activity timers
  int get remainingMinutes {
    final diff = triggerAt.difference(DateTime.now()).inMinutes;
    return diff > 0 ? diff : 0;
  }

  SmartReminder copyWith({
    String? id,
    String? prompt,
    DateTime? triggerAt,
    int? intervalCountdownMinutes,
    ReminderPriority? priority,
    bool? isCompleted,
  }) {
    return SmartReminder(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      triggerAt: triggerAt ?? this.triggerAt,
      intervalCountdownMinutes:
          intervalCountdownMinutes ?? this.intervalCountdownMinutes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'triggerAt': triggerAt.toIso8601String(),
      'intervalCountdownMinutes': intervalCountdownMinutes,
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      triggerAt: DateTime.parse(json['triggerAt'] as String),
      intervalCountdownMinutes: json['intervalCountdownMinutes'] as int?,
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReminderPriority.standard,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
