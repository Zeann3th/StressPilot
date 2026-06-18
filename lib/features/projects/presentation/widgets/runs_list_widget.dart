import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/navigation/app_router.dart';
import 'package:stress_pilot/features/results/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/results/presentation/provider/run_provider.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/status_badge.dart';

class RunsListWidget extends StatefulWidget {
  final int? flowId;
  final bool isSelectionMode;
  final Iterable<String> selectedIds;
  final Function(String, bool)? onSelectionChanged;

  const RunsListWidget({
    super.key,
    this.flowId,
    this.isSelectionMode = false,
    this.selectedIds = const [],
    this.onSelectionChanged,
  });

  @override
  State<RunsListWidget> createState() => _RunsListWidgetState();
}

class _RunsListWidgetState extends State<RunsListWidget> {
  final _runRepository = getIt<RunRepository>();
  List<Run>? _runs;
  bool _isLoading = false;
  final Set<String> _exportingRunIds = {};

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() => _isLoading = true);
    try {
      final runs = await _runRepository.getRuns(flowId: widget.flowId);
      runs.sort((a, b) => b.id.compareTo(a.id));
      setState(() => _runs = runs);
    } catch (e) {
      if (mounted) {
        PilotToast.show(context, 'Failed to load runs: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportRun(
    Run run, {
    RunExportFormat format = RunExportFormat.xlsx,
  }) async {
    if (_exportingRunIds.contains(run.id)) return;
    setState(() => _exportingRunIds.add(run.id));
    try {
      final File? file = await _runRepository.exportRun(run, format: format);
      if (mounted) {
        if (file == null) {
          PilotToast.show(context, 'Export returned empty', isError: true);
        } else {
          PilotToast.show(context, 'Exported to ${file.path}');
        }
      }
    } catch (e) {
      if (mounted) PilotToast.show(context, 'Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exportingRunIds.remove(run.id));
    }
  }

  Future<void> _handleRunTap(Run run) async {
    final status = run.status.toUpperCase();
    if (status == 'RUNNING' || status == 'STARTING') {
      Navigator.pushNamed(
        context,
        AppRouter.resultsRoute,
        arguments: {'runId': run.id},
      ).then((_) => _loadRuns());
    } else {
      final format = await _chooseExportFormat();
      if (format != null) {
        _exportRun(run, format: format);
      }
    }
  }

  Future<RunExportFormat?> _chooseExportFormat() {
    return showMenu<RunExportFormat>(
      context: context,
      position: const RelativeRect.fromLTRB(80, 80, 0, 0),
      items: RunExportFormat.values
          .map(
            (format) => PopupMenuItem(value: format, child: Text(format.label)),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = AppColors.surface;
    final border = AppColors.border;
    final textColor = AppColors.textPrimary;

    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surface,
            border: Border(
              bottom: BorderSide(
                color: border.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.flowId != null ? 'Flow Runs' : 'All Runs',
                style: AppTypography.heading.copyWith(color: textColor),
              ),
              const Spacer(),
              PilotButton.ghost(
                icon: Icons.refresh_rounded,
                onPressed: _loadRuns,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _RunSkeleton(isDark: isDark),
                )
              : _runs == null
              ? Center(
                  child: Text(
                    'Failed to load runs',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : _runs!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface.withValues(alpha: 0.6),
                          borderRadius: AppRadius.br12,
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.panel,
                        ),
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          size: 32,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No runs yet',
                        style: AppTypography.heading.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start a run from the Flow editor',
                        style: AppTypography.caption,
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
                )
              : RefreshIndicator(
                  onRefresh: _loadRuns,
                  color: AppColors.accent,
                  backgroundColor: surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _runs!.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _RunTile(
                      run: _runs![index],
                      isExporting: _exportingRunIds.contains(_runs![index].id),
                      onTap: () => _handleRunTap(_runs![index]),
                      onExportSelected: (format) =>
                          _exportRun(_runs![index], format: format),
                      onRefresh: _loadRuns,
                      isSelectionMode: widget.isSelectionMode,
                      isSelected: widget.selectedIds.contains(_runs![index].id),
                      onSelectionChanged: widget.onSelectionChanged,
                    )
                        .animate(delay: Duration(milliseconds: index * 45))
                        .slideX(begin: -0.04, end: 0, duration: 280.ms, curve: Curves.easeOut)
                        .fadeIn(duration: 280.ms),
                  ),
                ),
        ),
      ],
    );
  }
}

class _RunSkeleton extends StatelessWidget {
  final bool isDark;

  const _RunSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface;
    final border = AppColors.border;
    final skeletonColor = AppColors.divider;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.br6,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: skeletonColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunTile extends StatefulWidget {
  final Run run;
  final bool isExporting;
  final VoidCallback onTap;
  final ValueChanged<RunExportFormat> onExportSelected;
  final VoidCallback onRefresh;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(String, bool)? onSelectionChanged;

  const _RunTile({
    required this.run,
    required this.isExporting,
    required this.onTap,
    required this.onExportSelected,
    required this.onRefresh,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<_RunTile> createState() => _RunTileState();
}

class _RunTileState extends State<_RunTile> {
  bool _hovered = false;
  bool _isPressed = false;
  bool _isInterrupting = false;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimary;

    final status = widget.run.status.toUpperCase();
    final (statusColor, statusIcon) = _statusAppearance(status);
    final isRunning = status == 'RUNNING' || status == 'STARTING';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.isSelectionMode) {
          widget.onSelectionChanged?.call(widget.run.id, !widget.isSelected);
        } else {
          widget.onTap();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: TweenAnimationBuilder<double>(
          duration: AppDurations.short,
          tween: Tween(begin: 1.0, end: _isPressed ? 0.98 : 1.0),
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: RepaintBoundary(
            child: AnimatedContainer(
              duration: AppDurations.micro,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.accent.withValues(alpha: 0.06)
                    : _hovered
                    ? AppColors.accent.withValues(alpha: 0.03)
                    : AppColors.elevatedSurface.withValues(alpha: 0.88),
                borderRadius: AppRadius.br10,
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.accent.withValues(alpha: 0.7)
                      : _hovered
                      ? statusColor.withValues(alpha: 0.3)
                      : AppColors.border,
                  width: widget.isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  ...AppShadows.panel,
                  if (_hovered || widget.isSelected)
                    BoxShadow(
                      color: (widget.isSelected ? AppColors.accent : statusColor)
                          .withValues(alpha: widget.isSelected ? 0.2 : 0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.isSelectionMode && widget.isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (widget.isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.br8,
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Run #${widget.run.id}',
                                  style: AppTypography.body.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  color: statusColor,
                                  label: status,
                                  pulsing: isRunning,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Flow #${widget.run.flowId} • ${DateFormat('MMM d, HH:mm').format(widget.run.startedAt.toLocal())}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isSelectionMode) ...[
                        if (isRunning)
                          _isInterrupting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.stop_circle_outlined,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Abort Run',
                                  onPressed: () async {
                                    setState(() => _isInterrupting = true);
                                    try {
                                      await context
                                          .read<RunProvider>()
                                          .interruptRun(widget.run.id);
                                      widget.onRefresh();
                                    } catch (e) {
                                      if (mounted && context.mounted) {
                                        PilotToast.show(
                                          context,
                                          'Failed to abort: $e',
                                          isError: true,
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isInterrupting = false);
                                      }
                                    }
                                  },
                                ),
                        if (!isRunning)
                          widget.isExporting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : PopupMenuButton<RunExportFormat>(
                                  tooltip: 'Export',
                                  onSelected: widget.onExportSelected,
                                  itemBuilder: (context) =>
                                      RunExportFormat.values
                                          .map(
                                            (format) => PopupMenuItem(
                                              value: format,
                                              child: Text(format.label),
                                            ),
                                          )
                                          .toList(),
                                  child: Icon(
                                    Icons.download_rounded,
                                    color: AppColors.accent,
                                    size: 18,
                                  ),
                                ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatChip(
                        label: 'Threads',
                        value: widget.run.threads.toString(),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Duration',
                        value: widget.run.duration != null
                            ? '${widget.run.duration}s'
                            : '—',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Loops',
                        value: widget.run.loopCount?.toString() ?? '—',
                      ),
                      if (widget.run.completedAt != null) ...[
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Total',
                          value: _formatRuntime(
                            widget.run.startedAt,
                            widget.run.completedAt!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, IconData) _statusAppearance(String status) {
    switch (status) {
      case 'RUNNING':
      case 'STARTING':
        return (AppColors.info, Icons.play_circle_outline_rounded);
      case 'COMPLETED':
        return (AppColors.success, Icons.check_circle_outline_rounded);
      case 'FAILED':
      case 'ABORTED':
      case 'CANCELED':
        return (AppColors.error, Icons.error_outline_rounded);
      default:
        return (AppColors.textMuted, Icons.help_outline_rounded);
    }
  }

}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.hoverItem,
        borderRadius: AppRadius.br4,
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTypography.caption.copyWith(fontSize: 10),
            ),
            TextSpan(
              text: value,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontFamily: 'JetBrains Mono',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRuntime(DateTime start, DateTime end) {
  final diff = end.difference(start);
  if (diff.inHours > 0) {
    return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
  }
  if (diff.inMinutes > 0) {
    return '${diff.inMinutes}m ${diff.inSeconds.remainder(60)}s';
  }
  return '${diff.inSeconds}s';
}
