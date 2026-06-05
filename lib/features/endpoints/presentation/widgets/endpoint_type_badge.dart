import 'package:flutter/material.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';

class EndpointTypeBadge extends StatelessWidget {
  final String type;
  final bool compact;
  final bool inverse;

  const EndpointTypeBadge({
    super.key,
    required this.type,
    this.compact = false,
    this.inverse = false,
  });

  Color _colorForType(BuildContext context, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type.toUpperCase()) {
      case 'HTTP':
        return AppColors.methodPost;
      case 'GRPC':
        return AppColors.info;
      case 'WSS':
      case 'WS':
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
        return isDark ? AppColors.textSecondary : AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(context, type);
    final label = type.toUpperCase().length > 4 && compact
        ? type.toUpperCase().substring(0, 4)
        : type.toUpperCase();

    return PilotBadge(
      label: label,
      color: inverse ? Colors.white : color,
      compact: compact,
    );
  }
}
