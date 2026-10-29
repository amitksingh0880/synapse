import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_util.dart';
import '../../core/utils/haptics_util.dart';
import '../../models/routine_item.dart';
import '../../providers/hydration_provider.dart';
import '../../providers/memory_provider.dart';
import '../../providers/movement_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/android_foreground_voice_service.dart';
import '../../services/nlp_parser_service.dart';
import '../widgets/adherence_ring.dart';
import '../widgets/ambient_mic_capsule.dart';
import '../widgets/bento_card.dart';
import '../widgets/hydration_tile.dart';
import '../widgets/memory_vault_tile.dart';
import '../widgets/movement_tile.dart';
import '../widgets/pillbox_tile.dart';
import 'lock_screen_simulator_sheet.dart';
import 'query_sheet.dart';
import 'report_export_sheet.dart';

class HomeBentoScreen extends ConsumerStatefulWidget {
  const HomeBentoScreen({super.key});

  @override
  ConsumerState<HomeBentoScreen> createState() => _HomeBentoScreenState();
}

class _HomeBentoScreenState extends ConsumerState<HomeBentoScreen> {
  DaySector _activeSector = DateTimeUtil.getCurrentDaySector();
  final NLPParserService _nlpParser = NLPParserService();
  bool _isAmbientListening = true;
  bool _isBatteryOptimized = false;

  @override
  void initState() {
    super.initState();
    _checkAmbientStatus();
  }

  Future<void> _checkAmbientStatus() async {
    final running = await AndroidForegroundVoiceService.isRunning();
    final ignored =
        await AndroidForegroundVoiceService.isBatteryOptimizationIgnored();
    if (mounted) {
      setState(() {
        _isAmbientListening = running;
        _isBatteryOptimized = !ignored;
      });
    }
  }

  Future<void> _toggleAmbientListening() async {
    HapticsUtil.lightTick();
    if (_isAmbientListening) {
      await AndroidForegroundVoiceService.stopService();
      setState(() => _isAmbientListening = false);
    } else {
      await AndroidForegroundVoiceService.startService();
      setState(() => _isAmbientListening = true);
    }
  }

  void _handleAmbientCommand(String text) {
    final result = _nlpParser.parseIntent(text);

    switch (result.type) {
      case ParsedIntentType.createRoutine:
        if (result.routineItem != null) {
          ref.read(routineProvider.notifier).addRoutine(result.routineItem!);
        }
        break;
      case ParsedIntentType.logHydration:
        ref.read(hydrationProvider.notifier).addWater(result.intakeAmountMl ?? 250);
        break;
      case ParsedIntentType.logMovement:
        ref.read(movementProvider.notifier).recordMicroBreak();
        break;
      case ParsedIntentType.createMemory:
        if (result.memoryItem != null) {
          ref.read(memoryProvider.notifier).addMemory(result.memoryItem!);
        }
        break;
      case ParsedIntentType.createReminder:
        if (result.reminderItem != null) {
          ref.read(reminderProvider.notifier).addReminder(result.reminderItem!);
        }
        break;
      case ParsedIntentType.adherenceQuery:
      case ParsedIntentType.memoryQuery:
        _openQuerySheet();
        return;
      case ParsedIntentType.unknown:
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.feedbackMessage),
        backgroundColor: const Color(0xFF1C1C26),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openQuerySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuerySheet(),
    );
  }

  void _openReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportExportSheet(),
    );
  }

  void _openLockScreenSimulator() {
    HapticsUtil.mediumConfirm();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const LockScreenSimulatorSheet(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineProvider);
    final hydration = ref.watch(hydrationProvider);
    final movement = ref.watch(movementProvider);
    final memories = ref.watch(memoryProvider);

    final routineNotifier = ref.read(routineProvider.notifier);
    final sectorRoutines = routineNotifier.routinesForSector(_activeSector);
    final compliance = routineNotifier.todayCompliancePercentage;

    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.6),
            radius: 1.2,
            colors: [
              Color(0x1410B981),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Scrollable Bento Stream (Zero inner card scrollbars, all content expands naturally)
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 12, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Ambient Telemetry Indicator + Lock Screen Preview Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _toggleAmbientListening,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isAmbientListening
                                    ? AppColors.emeraldMeds.withOpacity(0.3)
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '●',
                                  style: TextStyle(
                                    color: _isAmbientListening
                                        ? AppColors.emeraldMeds
                                        : AppColors.amberReminders,
                                    fontSize: 8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isAmbientListening
                                      ? 'HEY BUDDY: ACTIVE'
                                      : 'AMBIENT WAKE: PAUSED',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    color: _isAmbientListening
                                        ? AppColors.emeraldMeds
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lock Screen Mode Simulator Chip
                        GestureDetector(
                          onTap: _openLockScreenSimulator,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14141E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔒', style: TextStyle(fontSize: 10)),
                                SizedBox(width: 6),
                                Text(
                                  'LOCK SCREEN HUD',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_isBatteryOptimized) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => AndroidForegroundVoiceService
                            .requestBatteryOptimizationExemption(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0x1FF59E0B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0x33F59E0B)),
                          ),
                          child: const Row(
                            children: [
                              Text('⚠️', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Grant Unrestricted Battery so Android Doze doesn\'t sleep "Hey Buddy"',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFFDE68A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateTimeUtil.formatHeaderDate().toUpperCase()} // 2026',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.white, Color(0xFF8E92A8)],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Synapse',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Clinical Score Gauge
                        GestureDetector(
                          onTap: _openReportSheet,
                          child: AdherenceRing(
                            percentage: compliance,
                            size: 46,
                            strokeWidth: 4,
                            centerWidget: Text(
                              '${(compliance * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sector Selector Ribbon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: DaySector.values.map((sector) {
                          final isSelected = sector == _activeSector;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticsUtil.lightTick();
                                setState(() {
                                  _activeSector = sector;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1E1E28)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected
                                      ? [
                                          const BoxShadow(
                                            color: Color(0x66000000),
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  sector.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hero Routine Bento Card (Expands naturally, zero inner scrollbars)
                    BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.emeraldMeds,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.emeraldMeds,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_activeSector.name.toUpperCase()} REGIMEN',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.emeraldMeds,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${sectorRoutines.where((r) => r.isCompletedToday).length}/${sectorRoutines.length} DONE',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (sectorRoutines.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'All doses complete for this sector.',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ...sectorRoutines.map((routine) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: PillboxTile(
                                  item: routine,
                                  onToggle: () => routineNotifier
                                      .toggleCompletion(routine.id),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Asymmetric Biometrics Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: HydrationTile(
                            state: hydration,
                            onAddWater: () =>
                                ref.read(hydrationProvider.notifier).addWater(250),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: MovementTile(
                            state: movement,
                            onRecordStretch: () =>
                                ref.read(movementProvider.notifier).recordMicroBreak(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Second Brain Vault Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SECOND BRAIN ENCRYPTED VAULT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.violetMemory,
                            letterSpacing: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openQuerySheet,
                          child: const Text(
                            'QUERY ALL',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: AppColors.violetMemory,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...memories.take(2).map((memory) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MemoryVaultTile(
                          item: memory,
                          onTap: _openQuerySheet,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Floating Jarvis Soundwave Dock
              Align(
                alignment: Alignment.bottomCenter,
                child: AmbientMicCapsule(
                  onCommandSubmitted: _handleAmbientCommand,
                  onOpenQueryModal: _openQuerySheet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
