import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_util.dart';
import '../../core/utils/haptics_util.dart';
import '../../providers/hydration_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/storage_service.dart';
import '../../services/wake_word_service.dart';

class LockScreenSimulatorSheet extends ConsumerStatefulWidget {
  const LockScreenSimulatorSheet({super.key});

  @override
  ConsumerState<LockScreenSimulatorSheet> createState() =>
      _LockScreenSimulatorSheetState();
}

class _LockScreenSimulatorSheetState
    extends ConsumerState<LockScreenSimulatorSheet> {
  late final WakeWordService _wakeWordService;
  String? _spokenResponse;
  bool _isSpeaking = false;
  String _lastQuery = 'Say "Hey Buddy, did I take my pills?"';

  @override
  void initState() {
    super.initState();
    _wakeWordService = WakeWordService(ref.read(storageServiceProvider));
  }

  Future<void> _simulateWakeWord(String query) async {
    HapticsUtil.doublePulseNudge();
    setState(() {
      _lastQuery = query;
      _isSpeaking = true;
      _spokenResponse = 'Processing query...';
    });

    final reply = await _wakeWordService.onKeywordDetected(query);
    if (mounted) {
      setState(() {
        _spokenResponse = reply;
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineProvider);
    final hydration = ref.watch(hydrationProvider);

    final nextPending = routines.firstWhere(
      (r) => !r.isCompletedToday,
      orElse: () => routines.isNotEmpty ? routines.first : null!,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF040406),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.1,
            colors: [
              Color(0x1F6366F1),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Lock Screen Status Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Synapse Ambient OS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lock Screen Big Clock
              Text(
                DateTimeUtil.formatHeaderDate(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB0B4C8),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '09:41',
                style: TextStyle(
                  fontSize: 78,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -3.0,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 36),

              // Lock Screen Live Glance Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101016).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldMeds,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SYNAPSE • GLANCE WIDGET',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emeraldMeds,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'LOCK SCREEN',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nextPending != null
                                      ? nextPending.title
                                      : 'All Doses Complete',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nextPending != null
                                      ? '${nextPending.dosage} • ${nextPending.sector.name.toUpperCase()}'
                                      : 'You are on track today',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${hydration.consumedMl} mL',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cyanWater,
                                ),
                              ),
                              Text(
                                '${(hydration.compliancePercentage * 100).toInt()}% WATER',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Zero-Unlock Action Buttons
                      Row(
                        children: [
                          if (nextPending != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.06),
                                  side: BorderSide(
                                    color: nextPending.isCompletedToday
                                        ? AppColors.emeraldMeds
                                        : Colors.white.withOpacity(0.12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  nextPending.isCompletedToday
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: nextPending.isCompletedToday
                                      ? AppColors.emeraldMeds
                                      : Colors.white,
                                ),
                                label: Text(
                                  nextPending.isCompletedToday
                                      ? 'Completed'
                                      : 'Mark Dose',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(routineProvider.notifier)
                                      .toggleCompletion(nextPending.id);
                                },
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.06),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.water_drop,
                                size: 16,
                                color: AppColors.cyanWater,
                              ),
                              label: const Text(
                                '+250ml Water',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(hydrationProvider.notifier)
                                    .addWater(250);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Lock Screen Voice HUD Capsule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSpeaking
                          ? AppColors.cyanWater
                          : AppColors.cyanWater.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mic,
                            color: _isSpeaking
                                ? AppColors.cyanWater
                                : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lastQuery,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_spokenResponse != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0x1F06B6D4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🎙️ Synapse: "$_spokenResponse"',
                            style: const TextStyle(
                              color: Color(0xFFA5F3FC),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Quick Action Voice Simulator Prompts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      label: const Text(
                        '🎙️ "Did I take my pills?"',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      onPressed: () => _simulateWakeWord(
                          'Did I take my morning pills today?'),
                    ),
                    ActionChip(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      label: const Text(
                        '🎙️ "Where is my car?"',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      onPressed: () =>
                          _simulateWakeWord('Where did I park my car?'),
                    ),
                    ActionChip(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      label: const Text(
                        '🎙️ "Drank 500ml water"',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      onPressed: () => _simulateWakeWord('Drank 500ml water'),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Swipe Up To Unlock indicator
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up, color: AppColors.textMuted, size: 24),
                    Text(
                      'TAP OR SWIPE UP TO RETURN',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
