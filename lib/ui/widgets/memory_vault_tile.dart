import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/memory_item.dart';
import 'bento_card.dart';

class MemoryVaultTile extends StatelessWidget {
  final MemoryItem item;
  final VoidCallback? onTap;

  const MemoryVaultTile({
    super.key,
    required this.item,
    this.onTap,
  });

  Color _categoryColor(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.location:
        return AppColors.cyanWater;
      case MemoryCategory.credential:
        return AppColors.amberReminders;
      case MemoryCategory.person:
        return AppColors.emeraldMeds;
      case MemoryCategory.fact:
      case MemoryCategory.general:
        return AppColors.violetMemory;
    }
  }

  IconData _categoryIcon(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.location:
        return Icons.location_on_rounded;
      case MemoryCategory.credential:
        return Icons.key_rounded;
      case MemoryCategory.person:
        return Icons.person_rounded;
      case MemoryCategory.fact:
      case MemoryCategory.general:
        return Icons.psychology_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(item.category);

    return BentoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_categoryIcon(item.category), size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    item.category.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                DateTimeUtil.relativeTimeSpan(item.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: item.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
