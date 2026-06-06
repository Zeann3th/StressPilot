import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/core/input/keymap_provider.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';

class KeymapSettingsTable extends StatefulWidget {
  const KeymapSettingsTable({super.key});

  @override
  State<KeymapSettingsTable> createState() => _KeymapSettingsTableState();
}

class _KeymapSettingsTableState extends State<KeymapSettingsTable> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeymapProvider>();
    final keymap = provider.keymap;
    final border = AppColors.border;
    final textColor = AppColors.textPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SHORTCUTS',
                    style: AppTypography.heading.copyWith(color: textColor),
                  ),
                  PilotButton.ghost(
                    label: 'Reset Defaults',
                    icon: Icons.refresh_rounded,
                    onPressed: () => provider.resetToDefaults(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.sidebarBackground,
                  borderRadius: AppRadius.br8,
                  border: Border.all(color: border, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final entry in keymap.entries) ...[
                      _buildRow(context, entry.key, entry.value),
                      if (entry.key != keymap.keys.last)
                        Divider(height: 1, color: AppColors.divider),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String actionId, String shortcut) {
    return _ShortcutRow(
      label: _humanizeActionId(actionId),
      shortcut: shortcut,
      onTap: () => _editShortcut(context, actionId, shortcut),
      textColor: AppColors.textPrimary,
    );
  }

  String _humanizeActionId(String actionId) {
    return actionId
        .split('.')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  Future<void> _editShortcut(
    BuildContext context,
    String actionId,
    String current,
  ) async {
    final provider = context.read<KeymapProvider>();
    String? newShortcut = await PilotDialog.show<String>(
      context: context,
      title: 'Edit Shortcut for ${_humanizeActionId(actionId)}',
      content: _ShortcutListener(
        initial: current,
        actionId: actionId,
        provider: provider,
        humanizeActionId: _humanizeActionId,
        onRecorded: (val) {
          Navigator.pop(context, val);
        },
        onCancel: () => Navigator.pop(context),
      ),
      actions: [
        PilotButton.ghost(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    if (newShortcut != null) {
      provider.updateShortcut(actionId, newShortcut);
    }
  }
}

class _ShortcutRow extends StatefulWidget {
  final String label;
  final String shortcut;
  final VoidCallback onTap;
  final Color textColor;

  const _ShortcutRow({
    required this.label,
    required this.shortcut,
    required this.onTap,
    required this.textColor,
  });

  @override
  State<_ShortcutRow> createState() => _ShortcutRowState();
}

class _ShortcutRowState extends State<_ShortcutRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.micro,
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  widget.label,
                  style: AppTypography.body.copyWith(
                    color: widget.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: AppRadius.br4,
                      ),
                      child: Text(
                        widget.shortcut,
                        style: AppTypography.code.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    if (_hovered) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutListener extends StatefulWidget {
  final String initial;
  final String actionId;
  final KeymapProvider provider;
  final String Function(String) humanizeActionId;
  final ValueChanged<String> onRecorded;
  final VoidCallback onCancel;

  const _ShortcutListener({
    required this.initial,
    required this.actionId,
    required this.provider,
    required this.humanizeActionId,
    required this.onRecorded,
    required this.onCancel,
  });

  @override
  State<_ShortcutListener> createState() => _ShortcutListenerState();
}

class _ShortcutListenerState extends State<_ShortcutListener> {
  final FocusNode _focusNode = FocusNode();
  String _current = "";
  String? _conflictActionId;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conflictLabel = _conflictActionId == null
        ? null
        : widget.humanizeActionId(_conflictActionId!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Press a key combination. Enter saves, Escape cancels, Backspace clears.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              _handleKeyPress(event);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: AppRadius.br8,
            ),
            alignment: Alignment.center,
            child: Text(
              _current.isEmpty ? 'Waiting for keys...' : _current,
              style: AppTypography.code.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _conflictActionId == null
                    ? AppColors.accent
                    : AppColors.warning,
              ),
            ),
          ),
        ),
        if (conflictLabel != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.triangleAlert,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Already used by $conflictLabel',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        PilotButton.primary(
          label: 'Save Shortcut',
          onPressed: _current.isEmpty || _conflictActionId != null
              ? null
              : () => widget.onRecorded(_current),
        ),
      ],
    );
  }

  void _handleKeyPress(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onCancel();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_current.isNotEmpty && _conflictActionId == null) {
        widget.onRecorded(_current);
      }
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      setState(() {
        _current = '';
        _conflictActionId = null;
      });
      return;
    }

    final keys = <String>[];
    if (HardwareKeyboard.instance.isControlPressed) keys.add('Control');
    if (HardwareKeyboard.instance.isShiftPressed) keys.add('Shift');
    if (HardwareKeyboard.instance.isAltPressed) keys.add('Alt');
    if (HardwareKeyboard.instance.isMetaPressed) keys.add('Meta');

    final keyLabel = _displayKey(event.logicalKey);
    if (!_isModifier(event.logicalKey)) {
      keys.add(keyLabel);
      setState(() {
        _current = keys.join('+');
        _conflictActionId = widget.provider.findActionUsingShortcut(
          _current,
          exceptActionId: widget.actionId,
        );
      });
    } else {
      setState(() {
        _current = keys.join('+');
        _conflictActionId = null;
      });
    }
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  String _displayKey(LogicalKeyboardKey key) {
    if (key.keyLabel.isNotEmpty && key.keyLabel.length == 1) {
      return key.keyLabel.toUpperCase();
    }
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.delete) return 'Delete';
    if (key == LogicalKeyboardKey.arrowUp) return 'ArrowUp';
    if (key == LogicalKeyboardKey.arrowDown) return 'ArrowDown';
    if (key == LogicalKeyboardKey.arrowLeft) return 'ArrowLeft';
    if (key == LogicalKeyboardKey.arrowRight) return 'ArrowRight';
    if (key == LogicalKeyboardKey.comma) return 'Comma';
    if (key == LogicalKeyboardKey.period) return 'Period';
    if (key == LogicalKeyboardKey.slash) return 'Slash';
    if (key == LogicalKeyboardKey.backslash) return 'Backslash';
    if (key == LogicalKeyboardKey.semicolon) return 'Semicolon';
    if (key == LogicalKeyboardKey.quote) return 'Quote';
    return key.keyLabel.isNotEmpty ? key.keyLabel : key.debugName ?? 'Key';
  }
}
