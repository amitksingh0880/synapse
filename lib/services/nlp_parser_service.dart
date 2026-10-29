import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/routine_item.dart';
import '../models/memory_item.dart';
import '../models/smart_reminder.dart';

enum ParsedIntentType {
  createRoutine,
  logHydration,
  logMovement,
  createMemory,
  createReminder,
  adherenceQuery,
  memoryQuery,
  unknown,
}

class ParsedIntentResult {
  final ParsedIntentType type;
  final String rawInput;
  final RoutineItem? routineItem;
  final MemoryItem? memoryItem;
  final SmartReminder? reminderItem;
  final int? intakeAmountMl;
  final String targetQuery;
  final String feedbackMessage;

  ParsedIntentResult({
    required this.type,
    required this.rawInput,
    this.routineItem,
    this.memoryItem,
    this.reminderItem,
    this.intakeAmountMl,
    this.targetQuery = '',
    required this.feedbackMessage,
  });
}

class NLPParserService {
  final Uuid _uuid = const Uuid();

  /// Parses natural spoken or written text into a structured intent
  ParsedIntentResult parseIntent(String text) {
    final clean = text.trim();
    final lower = clean.toLowerCase();

    // 1. Check for Adherence Verification Queries ("Did I take...")
    if (lower.startsWith('did i take') ||
        lower.startsWith('have i taken') ||
        lower.contains('did i drink')) {
      return ParsedIntentResult(
        type: ParsedIntentType.adherenceQuery,
        rawInput: clean,
        targetQuery: clean,
        feedbackMessage: 'Checking adherence records...',
      );
    }

    // 2. Check for Memory Retrieval Queries ("Where is...", "What is...")
    if (lower.startsWith('where ') ||
        lower.startsWith('what is ') ||
        lower.startsWith("what's ") ||
        lower.startsWith('who is ')) {
      return ParsedIntentResult(
        type: ParsedIntentType.memoryQuery,
        rawInput: clean,
        targetQuery: clean,
        feedbackMessage: 'Searching memory vault...',
      );
    }

    // 3. Check for Hydration Logging ("drank water", "had 500ml")
    if (lower.contains('water') || lower.contains('drank') || lower.contains('hydration')) {
      final mlMatch = RegExp(r'(\d+)\s*ml').firstMatch(lower);
      final int ml = mlMatch != null
          ? int.tryParse(mlMatch.group(1)!) ?? 250
          : 250;

      return ParsedIntentResult(
        type: ParsedIntentType.logHydration,
        rawInput: clean,
        intakeAmountMl: ml,
        feedbackMessage: 'Logged +$ml mL of water',
      );
    }

    // 4. Check for Movement / Stretch Logging
    if (lower.contains('stretch') ||
        lower.contains('walked') ||
        lower.contains('workout') ||
        lower.contains('steps')) {
      return ParsedIntentResult(
        type: ParsedIntentType.logMovement,
        rawInput: clean,
        feedbackMessage: 'Logged movement break',
      );
    }

    // 5. Check for Passive Second-Brain Memory ("Remember that...", "Note that...")
    if (lower.startsWith('remember ') ||
        lower.startsWith('note ') ||
        lower.contains('parked') ||
        lower.contains('code is') ||
        lower.contains('password is')) {
      return _extractMemory(clean, lower);
    }

    // 6. Check for Medication or Routine Creation ("Take 2 pills...", "3 medicines...")
    if (lower.contains('pill') ||
        lower.contains('medicine') ||
        lower.contains('medication') ||
        lower.contains('tablet') ||
        lower.contains('capsule') ||
        lower.contains('dose') ||
        lower.contains('mg') ||
        lower.startsWith('take ')) {
      return _extractRoutine(clean, lower);
    }

    // 7. Check for Reminders ("Remind me to...")
    if (lower.startsWith('remind me') || lower.contains('reminder')) {
      return _extractReminder(clean, lower);
    }

    return ParsedIntentResult(
      type: ParsedIntentType.unknown,
      rawInput: clean,
      feedbackMessage: 'Could not categorize action. Try: "Take 2 Panadol at 8am" or "Drank water"',
    );
  }

  // ---------------------------------------------------------------------------
  // Internal Entity Extractors
  // ---------------------------------------------------------------------------

  ParsedIntentResult _extractRoutine(String raw, String lower) {
    // Extract Time / Hour
    int hour = 8;
    int minute = 0;
    DaySector sector = DaySector.morning;

    // Matches explicit time representations (e.g. "at 8:30 am", "8:30am", "8:30", "at 8 am", "at 8", "8am", "8 pm")
    // Avoids falsely matching unadorned quantity counts like "take 2 pills"
    final timeMatch = RegExp(r'(?:at\s+)?(\d{1,2}):(\d{2})\s*(am|pm)?|(?:at\s+)(\d{1,2})\s*(am|pm)?|(\d{1,2})\s*(am|pm)').firstMatch(lower);
    if (timeMatch != null) {
      if (timeMatch.group(1) != null) {
        hour = int.tryParse(timeMatch.group(1)!) ?? 8;
        minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
        final meridian = timeMatch.group(3);
        if (meridian == 'pm' && hour < 12) hour += 12;
        if (meridian == 'am' && hour == 12) hour = 0;
      } else if (timeMatch.group(4) != null) {
        hour = int.tryParse(timeMatch.group(4)!) ?? 8;
        final meridian = timeMatch.group(5);
        if (meridian == 'pm' && hour < 12) hour += 12;
        if (meridian == 'am' && hour == 12) hour = 0;
      } else if (timeMatch.group(6) != null) {
        hour = int.tryParse(timeMatch.group(6)!) ?? 8;
        final meridian = timeMatch.group(7);
        if (meridian == 'pm' && hour < 12) hour += 12;
        if (meridian == 'am' && hour == 12) hour = 0;
      }
    }

    if (lower.contains('night') || lower.contains('evening') || hour >= 18) {
      sector = DaySector.evening;
    } else if (lower.contains('afternoon') || (hour >= 12 && hour < 18)) {
      sector = DaySector.afternoon;
    } else {
      sector = DaySector.morning;
    }

    // Extract Food Rule
    FoodRule food = FoodRule.none;
    if (lower.contains('with food') || lower.contains('with breakfast') || lower.contains('with meal')) {
      food = FoodRule.withFood;
    } else if (lower.contains('empty stomach') || lower.contains('before breakfast')) {
      food = FoodRule.emptyStomach;
    }

    // Extract Dosage / Pill Count
    final pillMatch = RegExp(r'(\d+)\s*(pills?|tablets?|capsules?)').firstMatch(lower);
    final count = pillMatch != null ? int.tryParse(pillMatch.group(1)!) ?? 1 : 1;

    // Title Heuristic: Extract word after "take"
    String title = 'Prescription Dose';
    final takeMatch = RegExp(r'take\s+(?:(\d+)\s+)?([a-zA-Z0-9\s]+?)(?:\s+pills?|\s+tablets?|\s+capsules?|\s+at|\s+every|\s+with|$)')
        .firstMatch(lower);
    if (takeMatch != null && takeMatch.group(2) != null) {
      title = takeMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        title = title[0].toUpperCase() + title.substring(1);
      }
    }

    final item = RoutineItem(
      id: _uuid.v4(),
      title: title,
      dosage: '$count pill${count > 1 ? 's' : ''}',
      type: RoutineType.medication,
      sector: sector,
      scheduledHour: hour,
      scheduledMinute: minute,
      foodRule: food,
      requiresFullGlassWater: true,
      dailyPillCount: count,
      currentInventory: 30, // Default 30-day initial assumption
    );

    return ParsedIntentResult(
      type: ParsedIntentType.createRoutine,
      rawInput: raw,
      routineItem: item,
      feedbackMessage: 'Scheduled ${item.title} ($count pills) for ${sector.name}',
    );
  }

  ParsedIntentResult _extractMemory(String raw, String lower) {
    MemoryCategory category = MemoryCategory.general;
    if (lower.contains('parked') || lower.contains('car') || lower.contains('level') || lower.contains('room')) {
      category = MemoryCategory.location;
    } else if (lower.contains('password') || lower.contains('code') || lower.contains('pin') || lower.contains('key')) {
      category = MemoryCategory.credential;
    } else if (lower.contains('wife') || lower.contains('husband') || lower.contains('birthday') || lower.contains('size')) {
      category = MemoryCategory.person;
    }

    // Strip lead words
    String cleanContent = raw
        .replaceFirst(RegExp(r'^(remember\s+that|remember|note\s+that|note)\s*', caseSensitive: false), '')
        .trim();

    final item = MemoryItem(
      id: _uuid.v4(),
      keyQuery: cleanContent,
      content: cleanContent,
      category: category,
      createdAt: DateTime.now(),
      tags: lower.split(RegExp(r'\s+')).where((t) => t.length > 3).toList(),
    );

    return ParsedIntentResult(
      type: ParsedIntentType.createMemory,
      rawInput: raw,
      memoryItem: item,
      feedbackMessage: 'Saved to encrypted ${category.name} vault',
    );
  }

  ParsedIntentResult _extractReminder(String raw, String lower) {
    final prompt = raw
        .replaceFirst(RegExp(r'^(remind\s+me\s+to|remind\s+me)\s*', caseSensitive: false), '')
        .trim();

    final item = SmartReminder(
      id: _uuid.v4(),
      prompt: prompt,
      triggerAt: DateTime.now().add(const Duration(hours: 1)), // default +1h
    );

    return ParsedIntentResult(
      type: ParsedIntentType.createReminder,
      rawInput: raw,
      reminderItem: item,
      feedbackMessage: 'Reminder set: $prompt',
    );
  }
}
