import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../models/routine_item.dart';
import '../models/hydration_state.dart';
import '../models/movement_state.dart';

class ClinicalAdherenceSummary {
  final double compliancePercentage;
  final int activeMedicationsCount;
  final int longestActiveStreak;
  final int averageDailyHydrationMl;
  final int totalMicroBreaksLogged;
  final String clinicalReportText;
  final DateTime generatedAt;

  ClinicalAdherenceSummary({
    required this.compliancePercentage,
    required this.activeMedicationsCount,
    required this.longestActiveStreak,
    required this.averageDailyHydrationMl,
    required this.totalMicroBreaksLogged,
    required this.clinicalReportText,
    required this.generatedAt,
  });
}

class AdherenceReportService {
  AdherenceReportService._();

  static ClinicalAdherenceSummary generateSummary({
    required List<RoutineItem> routines,
    required HydrationState hydration,
    required MovementState movement,
  }) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy - hh:mm a');

    int totalExpectedDoses = 0;
    int totalLoggedDoses = 0;
    int maxStreak = 0;

    for (final routine in routines) {
      if (routine.type == RoutineType.medication) {
        // Consider past 30 days
        totalExpectedDoses += 30;
        final logsInPast30Days = routine.completedLogs
            .where((d) => now.difference(d).inDays <= 30)
            .length;
        totalLoggedDoses += logsInPast30Days;

        if (routine.streakCount > maxStreak) {
          maxStreak = routine.streakCount;
        }
      }
    }

    final double compliance = totalExpectedDoses > 0
        ? ((totalLoggedDoses / totalExpectedDoses) * 100).clamp(0.0, 100.0)
        : 100.0;

    final buffer = StringBuffer();
    buffer.writeln('====================================================');
    buffer.writeln('       SYNAPSE CLINICAL ADHERENCE REPORT            ');
    buffer.writeln('====================================================');
    buffer.writeln('Generated: ${dateFormat.format(now)}');
    buffer.writeln('Patient Protocol Tracking: 30-Day Window\n');

    buffer.writeln('OVERALL COMPLIANCE SCORE: ${compliance.toStringAsFixed(1)}%');
    buffer.writeln('Longest Consistent Adherence Streak: $maxStreak Days\n');

    buffer.writeln('----------------------------------------------------');
    buffer.writeln('MEDICATION SCHEDULE & SUPPLY INVENTORY:');
    buffer.writeln('----------------------------------------------------');

    for (final routine in routines) {
      if (routine.type == RoutineType.medication) {
        final supply = routine.currentInventory != null
            ? '${routine.currentInventory} remaining (~${routine.daysOfSupplyRemaining ?? 0} days)'
            : 'Unmonitored';
        final status = routine.isRefillNeeded ? '⚠️ REFILL URGENT' : 'Optimal';
        final food = routine.foodRule != FoodRule.none
            ? ' | ${routine.foodRule.name}'
            : '';

        buffer.writeln('• ${routine.title.padRight(22)}: ${routine.dosage}$food');
        buffer.writeln('  Sector: ${routine.sector.name.toUpperCase()} (${routine.scheduledHour.toString().padLeft(2, '0')}:${routine.scheduledMinute.toString().padLeft(2, '0')})');
        buffer.writeln('  Current Supply: $supply | Status: $status\n');
      }
    }

    buffer.writeln('----------------------------------------------------');
    buffer.writeln('BIOMETRIC & LIFESTYLE BIOMARKERS:');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('• Average Daily Hydration: ${hydration.consumedMl} mL / ${hydration.targetMl} mL goal');
    buffer.writeln('• Daily Micro-Break / Stretch Compliance: ${movement.stretchesCompleted} / ${movement.dailyMovementGoal} sessions');
    buffer.writeln('• Estimated Daily Activity: ${movement.todaySteps} steps');
    buffer.writeln('====================================================');
    buffer.writeln('Confidential Medical Summary. Stored locally with on-device encryption.');

    return ClinicalAdherenceSummary(
      compliancePercentage: compliance,
      activeMedicationsCount: routines.where((r) => r.type == RoutineType.medication).length,
      longestActiveStreak: maxStreak,
      averageDailyHydrationMl: hydration.consumedMl,
      totalMicroBreaksLogged: movement.stretchesCompleted,
      clinicalReportText: buffer.toString(),
      generatedAt: now,
    );
  }
}
