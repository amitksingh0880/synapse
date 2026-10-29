import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/utils/haptics_util.dart';
import 'android_foreground_voice_service.dart';
import 'nlp_parser_service.dart';
import 'storage_service.dart';

class WakeWordService {
  final FlutterTts _tts = FlutterTts();
  final NLPParserService _nlpParser = NLPParserService();
  final StorageService _storageService;

  bool _isListening = false;
  bool get isListening => _isListening;

  Function(String spokenResponse)? onAnswerGenerated;
  Function()? onWakeWordTriggered;
  Function(String transcribedQuery)? onQueryRecognized;

  WakeWordService(this._storageService) {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5); // Natural conversational speed
    await _tts.awaitSpeakCompletion(true);
  }

  /// Starts the "Hey Buddy" ambient wake word listener
  Future<void> startWakeWordListening({
    Function()? onTrigger,
    Function(String)? onResponse,
    Function(String)? onQuery,
  }) async {
    onWakeWordTriggered = onTrigger;
    onAnswerGenerated = onResponse;
    onQueryRecognized = onQuery;
    _isListening = true;

    // Start Android Foreground Service for mic persistence
    await AndroidForegroundVoiceService.startService();
  }

  /// Called whenever the keyword "Hey Buddy" is detected
  Future<String> onKeywordDetected(String followedQuery) async {
    // 1. Wake screen over Android keyguard/lock screen
    await AndroidForegroundVoiceService.wakeScreenAndShow();

    // 2. Play tactile double-pulse
    await HapticsUtil.doublePulseNudge();
    onWakeWordTriggered?.call();
    onQueryRecognized?.call(followedQuery);

    // 3. Parse the question or command through on-device NLP
    final result = _nlpParser.parseIntent(followedQuery);
    String answerToSpeak = '';

    switch (result.type) {
      case ParsedIntentType.adherenceQuery:
        final routines = await _storageService.loadRoutines();
        final doneMeds = routines
            .where((r) => r.isCompletedToday)
            .map((r) => r.title)
            .toList();
        if (doneMeds.isNotEmpty) {
          answerToSpeak = 'Yes, Buddy. You have taken ${doneMeds.join(" and ")} today.';
        } else {
          answerToSpeak = 'No, your scheduled doses are still pending for today.';
        }
        break;

      case ParsedIntentType.memoryQuery:
        final memories = await _storageService.loadMemories();
        final match = memories.cast().firstWhere(
          (m) => m.matchesQuery(followedQuery),
          orElse: () => memories.isNotEmpty ? memories.first : null,
        );
        if (match != null) {
          answerToSpeak = 'According to your vault: ${match.content}.';
        } else {
          answerToSpeak = 'I could not find that in your second brain vault, Buddy.';
        }
        break;

      case ParsedIntentType.logHydration:
        final currentHydration = await _storageService.loadHydrationState();
        final amount = result.intakeAmountMl ?? 250;
        final updated = currentHydration.addIntake(amount);
        await _storageService.saveHydrationState(updated);
        answerToSpeak =
            'Logged $amount milliliters of water. Daily total is ${updated.consumedMl} milliliters.';
        break;

      case ParsedIntentType.logMovement:
        answerToSpeak = 'Recorded micro-break mobility stretch. Keep moving!';
        break;

      case ParsedIntentType.createRoutine:
        if (result.routineItem != null) {
          final routines = await _storageService.loadRoutines();
          await _storageService.saveRoutines([...routines, result.routineItem!]);
          answerToSpeak =
              'Scheduled ${result.routineItem!.title} for ${result.routineItem!.sector.name}.';
        }
        break;

      case ParsedIntentType.createMemory:
        if (result.memoryItem != null) {
          final memories = await _storageService.loadMemories();
          await _storageService.saveMemories([...memories, result.memoryItem!]);
          answerToSpeak = 'Securely stored in your local encrypted vault.';
        }
        break;

      case ParsedIntentType.createReminder:
        answerToSpeak = result.feedbackMessage;
        break;

      default:
        answerToSpeak =
            'I am listening, Buddy. You can ask if you took your pills, check your water, or ask where you parked.';
        break;
    }

    // 4. Speak answer aloud through phone speaker while locked
    onAnswerGenerated?.call(answerToSpeak);
    await _tts.speak(answerToSpeak);

    return answerToSpeak;
  }

  Future<void> stopWakeWordListening() async {
    _isListening = false;
    await _tts.stop();
    await AndroidForegroundVoiceService.stopService();
  }
}
