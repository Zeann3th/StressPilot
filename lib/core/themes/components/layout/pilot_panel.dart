import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';

class PilotPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool showBorder;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const PilotPanel({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.showBorder = true,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.br8;
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.baseBackground,
        borderRadius: radius,
        border: showBorder ? Border.all(color: AppColors.border) : null,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}
