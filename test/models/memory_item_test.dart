import 'package:flutter_test/flutter_test.dart';
import 'package:synapse/core/constants/app_constants.dart';
import 'package:synapse/models/memory_item.dart';

void main() {
  group('MemoryItem Tests', () {
    test('Matches fuzzy queries for recall', () {
      final memory = MemoryItem(
        id: 'mem_01',
        keyQuery: 'parking spot',
        content: 'Level 2, Spot B14 next to the elevator',
        category: MemoryCategory.location,
        createdAt: DateTime.now(),
        tags: ['car', 'parking', 'garage'],
      );

      expect(memory.matchesQuery('where is my car?'), isTrue);
      expect(memory.matchesQuery('parking'), isTrue);
      expect(memory.matchesQuery('what is the wifi password?'), isFalse);
    });

    test('Serializes to and from JSON', () {
      final memory = MemoryItem(
        id: 'mem_02',
        keyQuery: 'wifi password',
        content: 'Sunset404!',
        category: MemoryCategory.credential,
        createdAt: DateTime(2026, 10, 28, 14, 0),
        tags: ['wifi', 'office'],
      );

      final json = memory.toJson();
      final revived = MemoryItem.fromJson(json);

      expect(revived.id, 'mem_02');
      expect(revived.content, 'Sunset404!');
      expect(revived.category, MemoryCategory.credential);
    });
  });
}
