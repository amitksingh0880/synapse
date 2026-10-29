import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movement_state.dart';
import 'bento_card.dart';
import 'adherence_ring.dart';

class MovementTile extends StatelessWidget {
  final MovementState state;
  final VoidCallback onRecordStretch;

  const MovementTile({
    super.key,
    required this.state,
    required this.onRecordStretch,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      borderColor: state.isSedentaryAlertDue
          ? AppColors.coralCritical.withOpacity(0.5)
          : null,
      child: Row(
        children: [
          // Adherence Ring for Micro-Breaks
          AdherenceRing(
            percentage: state.progressPercentage,
            size: 50,
            strokeWidth: 5,
            activeColor: AppColors.indigoMovement,
            centerWidget: Text(
              '${state.stretchesCompleted}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Inactivity status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sedentary Monitor',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (state.isSedentaryAlertDue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coralCriticalGlow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'STAND UP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.coralCritical,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.hourlySittingMinutes}m sitting • ${state.todaySteps} steps today',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Micro-Break Action
          GestureDetector(
            onTap: onRecordStretch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Stretch',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.indigoMovement,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
