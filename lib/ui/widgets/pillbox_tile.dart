import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/routine_item.dart';

class PillboxTile extends StatelessWidget {
  final RoutineItem item;
  final VoidCallback onToggle;

  const PillboxTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = item.isCompletedToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDone ? Colors.white.withOpacity(0.015) : Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? Colors.white.withOpacity(0.02)
              : (item.isRefillNeeded ? AppColors.coralCritical.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // 1-Tap Toggle Circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.emeraldMeds : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.emeraldMeds : Colors.white.withOpacity(0.22),
                  width: 1.5,
                ),
                boxShadow: isDone
                    ? const [
                        BoxShadow(
                          color: AppColors.emeraldMedsGlow,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 12),

            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (item.isCritical) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.coralCriticalGlow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CRITICAL',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.coralCritical,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.dosage,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.foodRule != FoodRule.none) ...[
                        const Text(' • ', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        Text(
                          item.foodRule == FoodRule.withFood ? 'With Food' : 'Empty Stomach',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.amberReminders,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (item.isRefillNeeded) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.coralCriticalGlow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⚠️ ${item.daysOfSupplyRemaining ?? 0}d left',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.coralCritical,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Time Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Text(
                '${item.scheduledHour.toString().padLeft(2, '0')}:${item.scheduledMinute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
