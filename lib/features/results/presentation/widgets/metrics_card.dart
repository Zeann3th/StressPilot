import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/glow_card.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/animated_counter.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/pulse_indicator.dart';

class MetricsCard extends StatefulWidget {
  final String title;
  final double numericValue;
  final String Function(double) formatter;
  final IconData icon;
  final Color color;
  final bool isActive;

  const MetricsCard({
    super.key,
    required this.title,
    required this.numericValue,
    required this.formatter,
    required this.icon,
    required this.color,
    this.isActive = false,
  });

  @override
  State<MetricsCard> createState() => _MetricsCardState();
}

class _MetricsCardState extends State<MetricsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  late final Animation<double> _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
      .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MetricsCard old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _pulseController
        ..stop()
        ..value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => GlowCard(
        glowColor: widget.color,
        glowIntensity: widget.isActive ? _pulseAnim.value : 0.5,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.br8,
              border: Border.all(color: widget.color.withValues(alpha: 0.3)),
            ),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(widget.title, style: AppTypography.caption),
                    if (widget.isActive) ...[
                      const SizedBox(width: 6),
                      const PulseIndicator(size: 5),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedCounter(
                  value: widget.numericValue,
                  formatter: widget.formatter,
                  style: AppTypography.heading.copyWith(
                    fontSize: 20,
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
