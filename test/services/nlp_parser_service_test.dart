import 'package:flutter_test/flutter_test.dart';
import 'package:synapse/core/constants/app_constants.dart';
import 'package:synapse/services/nlp_parser_service.dart';

void main() {
  late NLPParserService parser;

  setUp(() {
    parser = NLPParserService();
  });

  group('NLPParserService Zero-Latency Intent Parsing', () {
    test('Parses medication routine phrase', () {
      final result = parser.parseIntent('Take 2 Metformin pills at 8:30 am every morning with breakfast');
      
      expect(result.type, ParsedIntentType.createRoutine);
      expect(result.routineItem, isNotNull);
      expect(result.routineItem!.title.toLowerCase(), contains('metformin'));
      expect(result.routineItem!.sector, DaySector.morning);
      expect(result.routineItem!.scheduledHour, 8);
      expect(result.routineItem!.scheduledMinute, 30);
      expect(result.routineItem!.foodRule, FoodRule.withFood);
    });

    test('Parses hydration logging phrase', () {
      final result = parser.parseIntent('Just drank a glass of water');

      expect(result.type, ParsedIntentType.logHydration);
      expect(result.intakeAmountMl, 250);

      final result500 = parser.parseIntent('Had 500 ml water');
      expect(result500.type, ParsedIntentType.logHydration);
      expect(result500.intakeAmountMl, 500);
    });

    test('Parses passive memory capture phrase', () {
      final result = parser.parseIntent('Remember that my car is parked at level 2 spot B14');

      expect(result.type, ParsedIntentType.createMemory);
      expect(result.memoryItem, isNotNull);
      expect(result.memoryItem!.category, MemoryCategory.location);
      expect(result.memoryItem!.content.toLowerCase(), contains('level 2 spot b14'));
    });

    test('Parses adherence verification query', () {
      final result = parser.parseIntent('Did I take my morning pills today?');

      expect(result.type, ParsedIntentType.adherenceQuery);
      expect(result.targetQuery.toLowerCase(), contains('morning pills'));
    });

    test('Parses general retrieval query', () {
      final result = parser.parseIntent('Where did I park my car?');

      expect(result.type, ParsedIntentType.memoryQuery);
      expect(result.targetQuery.toLowerCase(), contains('park'));
    });
  });
}
