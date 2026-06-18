import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_sheet.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_element.dart';
import 'package:stress_pilot/features/results/presentation/provider/custom_report_provider.dart';

class CustomReportSheetDialog extends StatefulWidget {
  const CustomReportSheetDialog({super.key});

  @override
  State<CustomReportSheetDialog> createState() =>
      _CustomReportSheetDialogState();
}

class _CustomReportSheetDialogState extends State<CustomReportSheetDialog> {
  CustomReportSheet? _selectedSheet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomReportProvider>().loadSheets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PilotDialog(
      title: 'Custom Report Sheets',
      maxWidth: 800,
      content: SizedBox(
        height: 500,
        child: Consumer<CustomReportProvider>(
          builder: (ctx, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Row(
              children: [
                // Left: sheet list
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.sheets.length,
                          itemBuilder: (_, i) {
                            final sheet = provider.sheets[i];
                            final selected = _selectedSheet?.id == sheet.id;
                            return ListTile(
                              title: Text(
                                sheet.name,
                                style: AppTypography.label.copyWith(
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedSheet = sheet),
                              trailing: PilotButton.ghost(
                                icon: LucideIcons.trash2,
                                compact: true,
                                onPressed: () async {
                                  await provider.deleteSheet(sheet.id);
                                  if (_selectedSheet?.id == sheet.id) {
                                    setState(() => _selectedSheet = null);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PilotButton.ghost(
                          label: '+ Add Sheet',
                          onPressed: () =>
                              _showAddSheetDialog(context, provider),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right: elements for selected sheet
                Expanded(
                  child: _selectedSheet == null
                      ? Center(
                          child: Text(
                            'Select a sheet',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : _buildElementsList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        PilotButton.primary(
          label: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildElementsList(
      BuildContext context, CustomReportProvider provider) {
    // refresh _selectedSheet from provider (may have updated elements)
    final current = provider.sheets
        .where((s) => s.id == _selectedSheet!.id)
        .firstOrNull;
    if (current == null) return const SizedBox.shrink();
    final elements = current.elements;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: elements.length,
            itemBuilder: (_, i) {
              final el = elements[i];
              return ListTile(
                leading: _typeBadge(el.type),
                title: Text(el.name, style: AppTypography.label),
                subtitle: Text(
                  el.type,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PilotButton.ghost(
                      icon: LucideIcons.pencil,
                      compact: true,
                      onPressed: () =>
                          _showElementDialog(context, provider, element: el),
                    ),
                    PilotButton.ghost(
                      icon: LucideIcons.trash2,
                      compact: true,
                      onPressed: () =>
                          provider.deleteElement(current.id, el.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PilotButton.ghost(
            label: '+ Add Element',
            onPressed: () => _showElementDialog(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _typeBadge(String type) {
    final colors = {
      'STAT': Colors.purple,
      'LINE': Colors.blue,
      'BAR': Colors.orange,
      'PIE': Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (colors[type] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: AppTypography.caption.copyWith(
          color: colors[type] ?? Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddSheetDialog(BuildContext ctx, CustomReportProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => PilotDialog(
        title: 'New Sheet',
        content: PilotInput(controller: ctrl, placeholder: 'Sheet name'),
        actions: [
          PilotButton.ghost(
            label: 'Cancel',
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          PilotButton.primary(
            label: 'Create',
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await provider.createSheet(
                  name: ctrl.text.trim(),
                  displayOrder: provider.sheets.length,
                );
                if (mounted) Navigator.pop(dialogCtx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showElementDialog(
    BuildContext ctx,
    CustomReportProvider provider, {
    CustomReportElement? element,
  }) {
    final sheetId = _selectedSheet!.id;
    final nameCtrl = TextEditingController(text: element?.name ?? '');
    String selectedType = element?.type ?? 'STAT';
    // type-specific controllers
    final exprCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    // series/slices as raw JSON text for simplicity
    final configCtrl = TextEditingController(text: element?.config ?? '');

    // pre-fill from existing config
    if (element?.config != null) {
      try {
        final cfg = jsonDecode(element!.config!) as Map<String, dynamic>;
        exprCtrl.text = cfg['expression'] as String? ?? '';
        labelCtrl.text = cfg['label'] as String? ?? '';
        unitCtrl.text = cfg['unit'] as String? ?? '';
      } catch (_) {}
    }

    showDialog(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (sCtx, setSt) {
          return PilotDialog(
            title: element == null ? 'New Element' : 'Edit Element',
            maxWidth: 500,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: AppTypography.label),
                  const SizedBox(height: 4),
                  PilotInput(
                      controller: nameCtrl, placeholder: 'Element name'),
                  const SizedBox(height: 12),
                  Text('Type', style: AppTypography.label),
                  const SizedBox(height: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: ['STAT', 'LINE', 'BAR', 'PIE']
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setSt(() => selectedType = v!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedType == 'STAT') ...[
                    Text('SpEL Expression', style: AppTypography.label),
                    const SizedBox(height: 4),
                    PilotInput(
                      controller: exprCtrl,
                      placeholder: 'e.g. #report.successRate',
                    ),
                    const SizedBox(height: 8),
                    PilotInput(
                        controller: labelCtrl, placeholder: 'Label'),
                    const SizedBox(height: 8),
                    PilotInput(
                        controller: unitCtrl,
                        placeholder: 'Unit (e.g. %)'),
                  ] else ...[
                    Text('Config JSON', style: AppTypography.label),
                    const SizedBox(height: 4),
                    PilotInput(
                      controller: configCtrl,
                      placeholder: selectedType == 'LINE'
                          ? '{"xAxisLabel":"Time","yAxisLabel":"ms","series":[{"name":"Avg ms","expression":"#bucket.avgMs"}]}'
                          : selectedType == 'BAR'
                              ? '{"xAxisLabel":"Endpoint","yAxisLabel":"ms","series":[{"name":"Avg ms","expression":"#stat.avgMs"}]}'
                              : '{"slices":[{"label":"Pass","expression":"#report.successCount"},{"label":"Fail","expression":"#report.failureCount"}]}',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedType == 'LINE'
                          ? 'Series expression variables: #bucket.avgMs, #bucket.rps, #bucket.p90Ms, #bucket.p95Ms, #bucket.activeThreads'
                          : selectedType == 'BAR'
                              ? 'Series expression variables: #stat.endpointName, #stat.avgMs, #stat.p90Ms, #stat.p95Ms, #stat.requests'
                              : 'Slice expression variables: #report.successCount, #report.failureCount, #report.totalRequests',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              PilotButton.ghost(
                label: 'Cancel',
                onPressed: () => Navigator.pop(dialogCtx),
              ),
              PilotButton.primary(
                label: element == null ? 'Create' : 'Save',
                onPressed: () async {
                  String config;
                  if (selectedType == 'STAT') {
                    config = jsonEncode({
                      'expression': exprCtrl.text.trim(),
                      'label': labelCtrl.text.trim(),
                      'unit': unitCtrl.text.trim(),
                    });
                  } else {
                    config = configCtrl.text.trim();
                  }

                  if (element == null) {
                    await provider.createElement(
                      sheetId,
                      name: nameCtrl.text.trim(),
                      type: selectedType,
                      config: config,
                      displayOrder: 0,
                    );
                  } else {
                    await provider.updateElement(
                      sheetId,
                      element.id,
                      name: nameCtrl.text.trim(),
                      type: selectedType,
                      config: config,
                    );
                  }
                  if (mounted) Navigator.pop(dialogCtx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
