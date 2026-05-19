import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/navigation/app_router.dart';
import 'package:stress_pilot/features/projects/presentation/widgets/runs_list_widget.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';

class RecentRunsPage extends StatefulWidget {
  const RecentRunsPage({super.key});

  @override
  State<RecentRunsPage> createState() => _RecentRunsPageState();
}

class _RecentRunsPageState extends State<RecentRunsPage> {
  bool _isCompareMode = false;
  final List<String> _selectedIds = [];

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

  void _navigateToComparison() {
    if (_selectedIds.length == 2) {
      AppNavigator.pushNamed(
        AppRouter.runComparisonRoute,
        arguments: {'runId1': _selectedIds[0], 'runId2': _selectedIds[1]},
      );
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
                foregroundOverride: _isCompareMode ? AppColors.accent : AppColors.textMuted,
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
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.baseBackground,
                  borderRadius: AppRadius.br12,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.panel,
                ),
                clipBehavior: Clip.antiAlias,
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
              onPressed: _navigateToComparison,
              label: const Text('Compare'),
              icon: const Icon(lucide.LucideIcons.gitCompare),
              backgroundColor: AppColors.accent,
            )
          : null,
    );
  }
}
