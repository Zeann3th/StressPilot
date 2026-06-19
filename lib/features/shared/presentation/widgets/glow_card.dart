import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';

class GlowCard extends StatelessWidget {
  final Widget? child;
  final Color? glowColor;
  final double glowIntensity;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GlowCard({
    super.key,
    this.child,
    this.glowColor,
    this.glowIntensity = 1.0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.br12;
    final hasGlow = glowColor != null && glowIntensity > 0;

    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface.withValues(alpha: 0.88),
          borderRadius: effectiveRadius,
          border: Border.all(
            color: hasGlow
                ? glowColor!.withValues(alpha: 0.5 * glowIntensity)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            ...AppShadows.panel,
            if (hasGlow)
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.35 * glowIntensity),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}
