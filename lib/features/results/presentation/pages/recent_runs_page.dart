import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/features/results/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/projects/presentation/widgets/runs_list_widget.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';

class RecentRunsPage extends StatefulWidget {
  const RecentRunsPage({super.key});

  @override
  State<RecentRunsPage> createState() => _RecentRunsPageState();
}

class _RecentRunsPageState extends State<RecentRunsPage> {
  bool _isCompareMode = false;
  bool _isExportingComparison = false;
  final List<String> _selectedIds = [];
  final _runRepository = getIt<RunRepository>();

  void _onSelectionChanged(String id, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedIds.contains(id)) {
          _selectedIds.add(id);
        }
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _exportComparison() async {
    if (_selectedIds.length != 2 || _isExportingComparison) return;

    setState(() => _isExportingComparison = true);
    try {
      final file = await _runRepository.exportRunComparison(
        _selectedIds[0],
        _selectedIds[1],
      );
      if (!mounted) return;
      if (file == null) {
        PilotToast.show(context, 'Comparison export canceled');
      } else {
        PilotToast.show(context, 'Comparison exported to ${file.path}');
        setState(() {
          _isCompareMode = false;
          _selectedIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        PilotToast.show(context, 'Comparison export failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingComparison = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseBackground,
      body: Column(
        children: [
          FleetPageBar(
            title: 'Recent Runs',
            showBack: true,
            actions: [
              PilotButton.ghost(
                icon: lucide.LucideIcons.gitCompare,
                foregroundOverride: _isCompareMode
                    ? AppColors.accent
                    : AppColors.textMuted,
                onPressed: () {
                  setState(() {
                    _isCompareMode = !_isCompareMode;
                    if (!_isCompareMode) {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PilotPanel(
                padding: EdgeInsets.zero,
                borderRadius: AppRadius.br8,
                boxShadow: AppShadows.subtle,
                child: RunsListWidget(
                  isSelectionMode: _isCompareMode,
                  selectedIds: _selectedIds,
                  onSelectionChanged: _onSelectionChanged,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isCompareMode && _selectedIds.length == 2
          ? FloatingActionButton.extended(
              onPressed: _isExportingComparison ? null : _exportComparison,
              label: Text(
                _isExportingComparison ? 'Exporting' : 'Export report',
              ),
              icon: _isExportingComparison
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(lucide.LucideIcons.fileSpreadsheet),
              backgroundColor: AppColors.accent,
            )
          : null,
    );
  }
}
