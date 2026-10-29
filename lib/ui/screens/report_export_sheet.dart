import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics_util.dart';
import '../../providers/hydration_provider.dart';
import '../../providers/movement_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/adherence_report_service.dart';
import '../widgets/bento_card.dart';

class ReportExportSheet extends ConsumerWidget {
  const ReportExportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);
    final hydration = ref.watch(hydrationProvider);
    final movement = ref.watch(movementProvider);

    final summary = AdherenceReportService.generateSummary(
      routines: routines,
      hydration: hydration,
      movement: movement,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.medical_services_rounded, color: AppColors.emeraldMeds, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Clinical Adherence Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stat Summary Bento Bar
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        '${summary.compliancePercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.emeraldMeds),
                      ),
                      const SizedBox(height: 4),
                      const Text('30-Day Score', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BentoCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        '${summary.longestActiveStreak}d',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.cyanWater),
                      ),
                      const SizedBox(height: 4),
                      const Text('Top Streak', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BentoCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        '${summary.activeMedicationsCount}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.amberReminders),
                      ),
                      const SizedBox(height: 4),
                      const Text('Active Meds', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Monospaced Clinical Summary Box
          Expanded(
            child: BentoCard(
              backgroundColor: AppColors.surfaceElevated,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: SelectableText(
                  summary.clinicalReportText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Copy / Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldMeds,
                foregroundColor: AppColors.textInverse,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text(
                'Copy Clinical Summary to Clipboard',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: summary.clinicalReportText));
                HapticsUtil.celebration();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report copied to clipboard! Ready to share with your physician.'),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
