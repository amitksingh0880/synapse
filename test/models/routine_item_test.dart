import 'package:flutter_test/flutter_test.dart';
import 'package:synapse/core/constants/app_constants.dart';
import 'package:synapse/models/routine_item.dart';

void main() {
  group('RoutineItem Domain Logic & Serialization', () {
    test('Calculates low supply alert accurately based on daily dosage', () {
      final routine = RoutineItem(
        id: 'med_001',
        title: 'Metformin',
        dosage: '500mg - 2 pills',
        type: RoutineType.medication,
        sector: DaySector.morning,
        scheduledHour: 8,
        scheduledMinute: 30,
        dailyPillCount: 2,
        currentInventory: 8,
        refillThresholdDays: 5,
        isCritical: true,
      );

      // 8 pills / 2 pills per day = 4 days remaining <= 5 threshold -> should alert
      expect(routine.daysOfSupplyRemaining, 4);
      expect(routine.isRefillNeeded, isTrue);
    });

    test('Marks completion for today and decrements inventory', () {
      final routine = RoutineItem(
        id: 'med_002',
        title: 'Omega 3',
        dosage: '1 capsule',
        type: RoutineType.medication,
        sector: DaySector.morning,
        scheduledHour: 9,
        scheduledMinute: 0,
        dailyPillCount: 1,
        currentInventory: 30,
        streakCount: 3,
      );

      expect(routine.isCompletedToday, isFalse);

      final completedRoutine = routine.markCompleted();
      expect(completedRoutine.isCompletedToday, isTrue);
      expect(completedRoutine.currentInventory, 29);
      expect(completedRoutine.streakCount, 4);
    });

    test('Serializes to and from JSON correctly', () {
      final routine = RoutineItem(
        id: 'med_003',
        title: 'Vitamin D3',
        dosage: '1000 IU',
        type: RoutineType.medication,
        sector: DaySector.morning,
        scheduledHour: 8,
        scheduledMinute: 0,
        foodRule: FoodRule.withFood,
        requiresFullGlassWater: true,
      );

      final json = routine.toJson();
      final revived = RoutineItem.fromJson(json);

      expect(revived.id, routine.id);
      expect(revived.title, 'Vitamin D3');
      expect(revived.foodRule, FoodRule.withFood);
      expect(revived.requiresFullGlassWater, isTrue);
    });
  });
}
