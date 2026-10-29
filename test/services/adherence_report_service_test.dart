import 'package:flutter_test/flutter_test.dart';
import 'package:synapse/core/constants/app_constants.dart';
import 'package:synapse/models/routine_item.dart';
import 'package:synapse/models/hydration_state.dart';
import 'package:synapse/models/movement_state.dart';
import 'package:synapse/services/adherence_report_service.dart';

void main() {
  group('AdherenceReportService Tests', () {
    test('Calculates overall 30-day compliance percentage and streak metrics', () {
      final now = DateTime.now();
      final routines = [
        RoutineItem(
          id: 'r1',
          title: 'Metformin',
          dosage: '500mg',
          sector: DaySector.morning,
          scheduledHour: 8,
          scheduledMinute: 0,
          completedLogs: [
            now,
            now.subtract(const Duration(days: 1)),
            now.subtract(const Duration(days: 2)),
          ],
          streakCount: 3,
        ),
      ];

      final hydration = HydrationState(targetMl: 2000, consumedMl: 1800);
      final movement = MovementState(stretchesCompleted: 6, todaySteps: 4200);

      final report = AdherenceReportService.generateSummary(
        routines: routines,
        hydration: hydration,
        movement: movement,
      );

      expect(report.compliancePercentage, greaterThan(0));
      expect(report.activeMedicationsCount, 1);
      expect(report.clinicalReportText, contains('CLINICAL ADHERENCE REPORT'));
      expect(report.clinicalReportText, contains('Metformin'));
    });
  });
}
