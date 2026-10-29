import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hydration_state.dart';
import 'bento_card.dart';

class HydrationTile extends StatefulWidget {
  final HydrationState state;
  final VoidCallback onAddWater;

  const HydrationTile({
    super.key,
    required this.state,
    required this.onAddWater,
  });

  @override
  State<HydrationTile> createState() => _HydrationTileState();
}

class _HydrationTileState extends State<HydrationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.state.progressPercentage * 100).toInt();

    return BentoCard(
      backgroundColor: const Color(0xFF0F141A),
      borderColor: AppColors.cyanWater.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cyanWaterGlow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.cyanWater),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HYDRATION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyanWater,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onAddWater,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyanWater,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cyanWaterGlow,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 12, color: AppColors.textInverse),
                      SizedBox(width: 2),
                      Text(
                        '250ml',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fluid Wave Canvas Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.black.withOpacity(0.4),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LiquidWavePainter(
                      progress: widget.state.progressPercentage,
                      animationValue: _waveController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.state.consumedMl}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyanWater,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Text(
                    '/ 2,500 mL GOAL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanWater,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _LiquidWavePainter({required this.progress, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = progress.clamp(0.0, 1.0);
    final baseHeight = size.height * (1.0 - clamped);

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    final step = animationValue * 2 * math.pi;

    for (double x = 0; x <= size.width; x += 6) {
      final y = baseHeight +
          math.sin((x / size.width * 2 * math.pi) + step) * 3 +
          math.cos((x / size.width * math.pi) + step * 0.8) * 2;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF06B6D4).withOpacity(0.75),
          const Color(0xFF38BDF8).withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, baseHeight, size.width, size.height - baseHeight));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress;
  }
}
