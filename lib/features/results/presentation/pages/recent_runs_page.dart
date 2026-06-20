import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/features/shared/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/results/presentation/widgets/runs_list_widget.dart';
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

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseBackground,
      body: Stack(
        children: [
          Column(
            children: [
              FleetPageBar(
                title: 'Recent Runs',
                showBack: true,
                actions: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: _showSearch ? 200 : 0,
                    height: 28,
                    child: _showSearch
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.hoverItem,
                              borderRadius: AppRadius.br6,
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: AppTypography.caption,
                              decoration: InputDecoration(
                                hintText: 'Search runs...',
                                hintStyle: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  PilotButton.ghost(
                    icon: _showSearch
                        ? lucide.LucideIcons.x
                        : lucide.LucideIcons.search,
                    foregroundOverride: _showSearch
                        ? AppColors.accent
                        : AppColors.textMuted,
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) _searchController.clear();
                      });
                    },
                  ),
                  PilotButton.ghost(
                    icon: lucide.LucideIcons.gitCompare,
                    foregroundOverride: _isCompareMode
                        ? AppColors.accent
                        : AppColors.textMuted,
                    onPressed: () {
                      setState(() {
                        _isCompareMode = !_isCompareMode;
                        if (!_isCompareMode) _selectedIds.clear();
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: _isCompareMode && _selectedIds.length == 2 ? 16 : -80,
            left: 16,
            right: 16,
            child: RepaintBoundary(
              child: _CompareBar(
                isExporting: _isExportingComparison,
                selectedCount: _selectedIds.length,
                onExport: _exportComparison,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareBar extends StatelessWidget {
  final bool isExporting;
  final int selectedCount;
  final VoidCallback onExport;

  const _CompareBar({
    required this.isExporting,
    required this.selectedCount,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: AppRadius.br12,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            lucide.LucideIcons.gitCompare,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Text(
            '$selectedCount of 2 runs selected',
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          PilotButton.primary(
            icon: lucide.LucideIcons.fileSpreadsheet,
            label: isExporting ? 'Exporting...' : 'Export Comparison',
            onPressed: isExporting ? null : onExport,
          ),
        ],
      ),
    );
  }
}
