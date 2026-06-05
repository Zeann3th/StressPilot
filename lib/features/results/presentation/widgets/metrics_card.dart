import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';

class MetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.elevatedSurface;
    final textColor = AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.br8,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.hoverItem,
              borderRadius: AppRadius.br6,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.9), size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.heading.copyWith(
                    fontSize: 16,
                    color: textColor,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
