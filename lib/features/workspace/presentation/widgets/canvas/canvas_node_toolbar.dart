import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/workspace/domain/models/canvas.dart';

class CanvasNodeToolbar extends StatelessWidget {
  const CanvasNodeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.br8,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarNodeItem(
            type: FlowNodeType.start,
            icon: LucideIcons.play,
            label: 'Start',
            color: colors.tertiary,
          ),
          const _Divider(),
          _ToolbarNodeItem(
            type: FlowNodeType.branch,
            icon: LucideIcons.gitBranch,
            label: 'Branch',
            color: colors.primary,
          ),
          const _Divider(),
          _ToolbarNodeItem(
            type: FlowNodeType.subflow,
            icon: LucideIcons.network,
            label: 'Subflow',
            color: colors.secondary,
          ),
        ],
      ),
    );
  }
}

class _ToolbarNodeItem extends StatefulWidget {
  final FlowNodeType type;
  final IconData icon;
  final String label;
  final Color color;

  const _ToolbarNodeItem({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_ToolbarNodeItem> createState() => _ToolbarNodeItemState();
}

class _ToolbarNodeItemState extends State<_ToolbarNodeItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dragData = DragData(
      type: widget.type,
      payload: {'name': widget.label},
    );

    return Draggable<DragData>(
      data: dragData,
      feedback: Material(
        color: Colors.transparent,
        child: _IconBody(
          icon: widget.icon,
          color: widget.color,
          isDragging: true,
          hovered: false,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: widget.label,
          child: _IconBody(
            icon: widget.icon,
            color: widget.color,
            isDragging: false,
            hovered: _hovered,
          ),
        ),
      ),
    );
  }
}

class _IconBody extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDragging;
  final bool hovered;

  const _IconBody({
    required this.icon,
    required this.color,
    required this.isDragging,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: hovered ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: AppRadius.br8,
        border: Border.all(
          color: isDragging ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: hovered || isDragging
            ? color
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
