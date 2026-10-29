import 'package:flutter_test/flutter_test.dart';
import 'package:synapse/models/hydration_state.dart';

void main() {
  group('HydrationState Tests', () {
    test('Calculates percentage and adds intake accurately', () {
      final initial = HydrationState(
        targetMl: 2000,
        consumedMl: 1000,
        defaultGlassSizeMl: 250,
      );

      expect(initial.progressPercentage, 0.5);
      expect(initial.glassesConsumed, 4);

      final updated = initial.addIntake(250);
      expect(updated.consumedMl, 1250);
      expect(updated.progressPercentage, 0.625);
      expect(updated.glassesConsumed, 5);
    });

    test('Caps progress percentage at 1.0 or handles overflow gracefully', () {
      final state = HydrationState(
        targetMl: 1000,
        consumedMl: 1250,
      );

      expect(state.progressPercentage, 1.0);
      expect(state.isGoalReached, isTrue);
    });

    test('Serializes to and from JSON', () {
      final state = HydrationState(
        targetMl: 2500,
        consumedMl: 750,
      );

      final json = state.toJson();
      final revived = HydrationState.fromJson(json);

      expect(revived.targetMl, 2500);
      expect(revived.consumedMl, 750);
    });
  });
}
