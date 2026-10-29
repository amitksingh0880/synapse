import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double borderRadius;

  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top light catch line
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            height: 1,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x33FFFFFF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: Colors.white.withOpacity(0.04),
              highlightColor: Colors.white.withOpacity(0.02),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
