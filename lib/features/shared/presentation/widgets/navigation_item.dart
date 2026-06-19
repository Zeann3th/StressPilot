import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/feedback/pilot_badge.dart';

class NavigationItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? badge;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;
  final bool isActive;

  const NavigationItem({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.icon,
    required this.onTap,
    this.compact = false,
    this.isActive = false,
  });

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isActive ? AppColors.accent : AppColors.textSecondary;
    final textColor = widget.isActive ? AppColors.accent : AppColors.textPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: AppDurations.micro,
                color: _hovered
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : widget.isActive
                    ? AppColors.accent.withValues(alpha: 0.05)
                    : Colors.transparent,
                padding: EdgeInsets.only(
                  left: widget.compact ? 14 : 18,
                  right: widget.compact ? 10 : 14,
                  top: widget.compact ? 6 : 8,
                  bottom: widget.compact ? 6 : 8,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 14, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: AppTypography.body.copyWith(
                              color: textColor,
                              fontWeight: widget.isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: widget.compact ? 13 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null &&
                              widget.subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              widget.subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: widget.compact ? 11 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.badge != null) ...[
                      const SizedBox(width: 8),
                      PilotBadge(
                        label: widget.badge!.toUpperCase(),
                        color: _getBadgeColor(widget.badge!),
                        compact: true,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isActive)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: AnimatedContainer(
                    duration: AppDurations.short,
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: const BorderRadius.only(
                        topRight: AppRadius.r4,
                        bottomRight: AppRadius.r4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String type) {
    switch (type.toUpperCase()) {
      case 'HTTP':
        return AppColors.methodPost;
      case 'GRPC':
        return AppColors.info;
      case 'WS':
      case 'WSS':
      case 'WEBSOCKET':
        return AppColors.warning;
      case 'GRAPHQL':
        return AppColors.methodPatch;
      case 'JDBC':
      case 'SQL':
        return AppColors.textSecondary;
      case 'JS':
      case 'JAVASCRIPT':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
