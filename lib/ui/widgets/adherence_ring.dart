import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AdherenceRing extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;
  final Color activeColor;

  const AdherenceRing({
    super.key,
    required this.percentage,
    this.size = 64,
    this.strokeWidth = 6,
    this.centerWidget,
    this.activeColor = AppColors.emeraldMeds,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            color: AppColors.border,
          ),
          // Active Track with glow
          CircularProgressIndicator(
            value: clamped,
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            color: activeColor,
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}
