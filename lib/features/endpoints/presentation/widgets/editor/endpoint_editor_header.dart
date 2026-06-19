import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';

class EndpointEditorHeader extends StatelessWidget {
  final String method;
  final TextEditingController urlController;
  final ValueChanged<String?> onMethodChanged;
  final ValueChanged<String> onUrlChanged;
  final VoidCallback onExportCurl;
  final VoidCallback onSave;

  const EndpointEditorHeader({
    super.key,
    required this.method,
    required this.urlController,
    required this.onMethodChanged,
    required this.onUrlChanged,
    required this.onExportCurl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.baseBackground,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56, // Slightly taller for Fleet feel
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _MethodDropdown(value: method, onChanged: onMethodChanged),
                const SizedBox(width: 12),
                Expanded(
                  child: _UrlField(
                    controller: urlController,
                    onChanged: onUrlChanged,
                  ),
                ),
                const SizedBox(width: 16),
                PilotButton.ghost(
                  icon: LucideIcons.code,
                  onPressed: onExportCurl,
                  compact: true,
                  tooltip: 'Export to cURL',
                ),
                const SizedBox(width: 8),
                PilotButton.ghost(
                  icon: LucideIcons.save,
                  onPressed: onSave,
                  compact: true,
                  tooltip: 'Save Endpoint',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  static final methodColorMap = {
    'GET': AppColors.methodGet,
    'POST': AppColors.methodPost,
    'PUT': AppColors.methodPut,
    'DELETE': AppColors.methodDelete,
    'PATCH': AppColors.methodPatch,
  };

  const _MethodDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final methodColor = methodColorMap[value] ?? AppColors.accent;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: methodColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.br6,
          border: Border.all(color: methodColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: methodColor.withValues(alpha: 0.18),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.elevatedSurface,
            icon: Icon(
              LucideIcons.chevronDown,
              size: 12,
              color: methodColor.withValues(alpha: 0.7),
            ),
            items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map((m) {
              final itemColor = methodColorMap[m] ?? AppColors.accent;
              return DropdownMenuItem(
                value: m,
                child: Text(
                  m,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _UrlField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _UrlField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: AppRadius.br4,
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.code.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'https://api.example.com/v1/resource',
          hintStyle: AppTypography.code.copyWith(
            color: AppColors.textDisabled,
            fontSize: 13,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
