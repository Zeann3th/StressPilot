import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';

class RunCompleteOverlay extends StatelessWidget {
  final bool isSuccess;

  const RunCompleteOverlay({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.error;
    final icon = isSuccess ? LucideIcons.checkCircle2 : LucideIcons.xCircle;
    final label = isSuccess ? 'Run Complete' : 'Run Failed';

    return IgnorePointer(
      child: Center(
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: AppRadius.br12,
              border: Border.all(color: color.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTypography.heading.copyWith(
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 200.ms)
              .then(delay: 1400.ms)
              .fadeOut(duration: 400.ms),
        ),
      ),
    );
  }
}
