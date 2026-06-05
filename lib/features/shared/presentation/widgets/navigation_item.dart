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

  const NavigationItem({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: AnimatedContainer(
            duration: AppDurations.micro,
            color: _hovered
                ? AppColors.accent.withValues(alpha: 0.08)
                : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14,
              vertical: widget.compact ? 6 : 8,
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
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
