import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics_util.dart';

class AmbientMicCapsule extends StatefulWidget {
  final Function(String query) onCommandSubmitted;
  final VoidCallback onOpenQueryModal;

  const AmbientMicCapsule({
    super.key,
    required this.onCommandSubmitted,
    required this.onOpenQueryModal,
  });

  @override
  State<AmbientMicCapsule> createState() => _AmbientMicCapsuleState();
}

class _AmbientMicCapsuleState extends State<AmbientMicCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      height: 64,
      padding: const EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101016).withOpacity(0.92),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Acoustic Dancing Visualizer + Prompt
          GestureDetector(
            onTap: widget.onOpenQueryModal,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Row(
                      children: [
                        _buildBar(6 + (_animController.value * 8), AppColors.cyanWater),
                        const SizedBox(width: 3),
                        _buildBar(14 - (_animController.value * 6), const Color(0xFF6366F1)),
                        const SizedBox(width: 3),
                        _buildBar(18 + (_animController.value * 4), AppColors.violetMemory),
                        const SizedBox(width: 3),
                        _buildBar(10 + (_animController.value * 8), AppColors.cyanWater),
                        const SizedBox(width: 3),
                        _buildBar(16 - (_animController.value * 8), AppColors.emeraldMeds),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ask Jarvis or speak...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Glowing Multi-color Orb
          GestureDetector(
            onTap: () {
              HapticsUtil.mediumConfirm();
              widget.onOpenQueryModal();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cyanWater, Color(0xFF6366F1), AppColors.violetMemory],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cyanWaterGlow,
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 2.5,
      height: height.clamp(4.0, 24.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
