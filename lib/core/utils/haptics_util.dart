import 'package:flutter/services.dart';

class HapticsUtil {
  HapticsUtil._();

  /// Light tactile feedback for micro-interactions (e.g. water droplet log)
  static Future<void> lightTick() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium feedback for checking off a pill or routine
  static Future<void> mediumConfirm() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy feedback for critical alerts or alarm acknowledges
  static Future<void> heavyAlert() async {
    await HapticFeedback.heavyImpact();
  }

  /// Distinct double-pulse for movement / sedentary inactivity nudge
  static Future<void> doublePulseNudge() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.lightImpact();
  }

  /// Celebratory pattern for closing all daily rings
  static Future<void> celebration() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }
}
