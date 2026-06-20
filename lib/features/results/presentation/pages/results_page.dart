import 'dart:async';
import 'dart:io';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/features/shared/presentation/provider/run_provider.dart';
import 'package:stress_pilot/features/results/presentation/provider/results_provider.dart';
import 'package:stress_pilot/features/shared/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/shared/domain/models/run.dart';
import 'package:stress_pilot/features/results/presentation/widgets/metrics_card.dart';
import 'package:stress_pilot/features/results/presentation/widgets/realtime_chart.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/navigation/app_router.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/features/results/presentation/provider/custom_report_provider.dart';
import 'package:stress_pilot/features/results/presentation/widgets/custom_report_sheet_dialog.dart';
import 'package:stress_pilot/features/results/presentation/widgets/run_complete_overlay.dart';

import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';

class ResultsPage extends StatefulWidget {
  final String runId;

  const ResultsPage({super.key, required this.runId});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Run? _currentRun;
  bool _loadingRun = false;

  Timer? _tickTimer;
  Duration _elapsed = Duration.zero;
  bool _exporting = false;
  bool _showRunComplete = false;
  bool _runCompleteIsSuccess = false;
  String? _lastKnownStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadRun();
      if (_currentRun != null && mounted) {
        _startTimers();
      }
    });
  }

  Duration _currentPollInterval = const Duration(seconds: 15);
  bool _isPolling = false;

  void _startTimers() {
    _startPolling();

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateElapsed(),
    );
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollLoop();
  }

  Future<void> _pollLoop() async {
    while (_isPolling && mounted) {
      await _refreshRun();

      if (_currentRun == null || _isTerminalStatus(_currentRun!.status)) {
        _isPolling = false;
        break;
      }

      Duration nextDelay = _currentPollInterval;

      final created = _currentRun!.startedAt;
      final elapsed = DateTime.now().toUtc().difference(created.toUtc());
      final duration = _currentRun!.duration;
      final remaining = duration != null
          ? Duration(seconds: duration) - elapsed
          : Duration.zero;

      if (duration == null) {
        nextDelay = const Duration(seconds: 2);
      } else if (remaining.inSeconds <= 5 || elapsed.inSeconds <= 10) {
        nextDelay = const Duration(seconds: 2);
      } else if (remaining.inSeconds > 0) {
        nextDelay = const Duration(seconds: 5);
      } else {
        nextDelay = _currentPollInterval + const Duration(seconds: 2);
        if (nextDelay > const Duration(seconds: 10)) {
          nextDelay = const Duration(seconds: 10);
        }
      }

      _currentPollInterval = nextDelay;
      await Future.delayed(_currentPollInterval);
    }
  }

  void _stopTimers() {
    _isPolling = false;
    _tickTimer?.cancel();
  }

  Future<void> _updateElapsed() async {
    if (_currentRun == null) return;

    try {
      final created = _currentRun!.startedAt;
      final newElapsed = DateTime.now().toUtc().difference(created.toUtc());
      setState(() {
        _elapsed = newElapsed;
      });

      if (!_isPolling && !_isTerminalStatus(_currentRun!.status)) {
        _startPolling();
      }
    } catch (_) {
      setState(() {
        _elapsed = _elapsed + const Duration(seconds: 1);
      });
    }
  }

  Future<void> _loadRun() async {
    setState(() => _loadingRun = true);
    try {
      final svc = getIt<RunRepository>();
      final run = await svc.getRun(widget.runId);
      final isTerminal = _isTerminalStatus(run.status);

      if (mounted) {
        context.read<ResultsProvider>().setRun(
          run.id,
          run.flowId,
          isCompleted: isTerminal,
        );
      }

      setState(() {
        _currentRun = run;
        try {
          final created = _currentRun!.startedAt;
          _elapsed = DateTime.now().toUtc().difference(created.toUtc());
        } catch (_) {
          _elapsed = Duration.zero;
        }
      });

      _lastKnownStatus = run.status.toUpperCase();

      if (isTerminal) {
        _stopTimers();
      }
    } catch (e) {
      debugPrint('Failed to load run: $e');
      if (mounted) {
        AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Failed to load run: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingRun = false);
    }
  }

  Future<void> _refreshRun() async {
    try {
      final svc = getIt<RunRepository>();
      final run = await svc.getRun(widget.runId);
      setState(() {
        _currentRun = run;
      });

      final newStatus = run.status.toUpperCase();
      final oldStatus = _lastKnownStatus;
      _lastKnownStatus = newStatus;

      if (oldStatus != null &&
          !_isTerminalStatus(oldStatus) &&
          _isTerminalStatus(newStatus) &&
          mounted) {
        setState(() {
          _showRunComplete = true;
          _runCompleteIsSuccess = newStatus == 'COMPLETED';
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() => _showRunComplete = false);
        });
      }

      if (_currentRun != null && _isTerminalStatus(_currentRun!.status)) {
        _stopTimers();
        if (mounted) {
          context.read<ResultsProvider>().stopChart();
        }
      }
    } catch (e) {
      debugPrint('Run refresh failed: $e');
    }
  }

  bool _isTerminalStatus(String status) {
    final s = status.toUpperCase();
    return s == 'COMPLETED' ||
        s == 'FAILED' ||
        s == 'ABORTED' ||
        s == 'CANCELED';
  }

  Future<void> _exportRun(RunExportFormat format) async {
    if (_currentRun == null) return;
    setState(() => _exporting = true);
    try {
      final svc = getIt<RunRepository>();
      final File? file = await svc.exportRun(_currentRun!, format: format);
      if (file == null) {
        AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Export returned empty')),
        );
      } else {
        AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Export saved to ${file.path}')),
        );
      }
    } catch (e) {
      debugPrint('Export failed: $e');
      AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      setState(() => _exporting = false);
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  bool _isRunActive() {
    if (_currentRun == null) return false;
    final s = _currentRun!.status.toUpperCase();
    return s == 'RUNNING' || s == 'STARTING';
  }

  Color _latencyColor(double ms) {
    if (ms < 200) return AppColors.success;
    if (ms < 500) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResultsProvider>();
    return Scaffold(
      backgroundColor: AppColors.baseBackground,
      body: Stack(
        children: [
          Column(
            children: [
              FleetPageBar(
                title: 'Results',
                actions: [
                  _buildEndpointDropdown(provider),
                  const SizedBox(width: 8),
                  _buildCustomSheetsButton(),
                  _buildAbortButton(),
                  _buildExportButton(),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: PilotPanel(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    borderRadius: AppRadius.br8,
                    boxShadow: AppShadows.subtle,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildRunInfoCard()),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: MetricsCard(
                                title: 'Total Requests',
                                numericValue: provider.totalRequests.toDouble(),
                                formatter: (v) => v.toInt().toString(),
                                icon: LucideIcons.hash,
                                color: AppColors.info,
                                isActive: _isRunActive(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: MetricsCard(
                                title: 'Avg Response',
                                numericValue: provider.avgResponseTime,
                                formatter: (v) => '${v.toStringAsFixed(0)} ms',
                                icon: LucideIcons.timer,
                                color: _latencyColor(provider.avgResponseTime),
                                isActive: _isRunActive(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: MetricsCard(
                                title: 'Req / Sec',
                                numericValue: provider.requestsPerSecond,
                                formatter: (v) => v.toStringAsFixed(1),
                                icon: LucideIcons.gauge,
                                color: AppColors.success,
                                isActive: _isRunActive(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: MetricsCard(
                                title: 'Errors',
                                numericValue: provider.errorCount.toDouble(),
                                formatter: (v) => v.toInt().toString(),
                                icon: LucideIcons.triangleAlert,
                                color: provider.errorCount > 0 ? AppColors.error : AppColors.success,
                                isActive: _isRunActive(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: RealtimeChart(
                                  title: 'Response Time (ms)',
                                  data: provider.responseTimePoints,
                                  color: AppColors.warning,
                                  isActive: _isRunActive(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: RealtimeChart(
                                  title: 'Requests Per Second',
                                  data: provider.rpsPoints,
                                  color: AppColors.success,
                                  isYAxisInteger: true,
                                  isActive: _isRunActive(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showRunComplete)
            RunCompleteOverlay(isSuccess: _runCompleteIsSuccess),
        ],
      ),
    );
  }

  Widget _buildEndpointDropdown(ResultsProvider provider) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.hoverItem,
        borderRadius: AppRadius.br6,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: provider.selectedEndpointId,
          hint: Text(
            'All Endpoints',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          dropdownColor: AppColors.elevatedSurface,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 14,
            color: AppColors.textSecondary,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Endpoints',
                style: AppTypography.body.copyWith(fontSize: 12),
              ),
            ),
            ...provider.endpointNames.entries.map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(
                  e.value,
                  style: AppTypography.body.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: (v) => provider.setEndpointFilter(v),
        ),
      ),
    );
  }

  Widget _buildAbortButton() {
    return Consumer<RunProvider>(
      builder: (context, runProvider, child) {
        final isTerminal =
            _currentRun == null || _isTerminalStatus(_currentRun!.status);
        if (isTerminal) return const SizedBox.shrink();
        return Tooltip(
          message: 'Abort Run',
          child: IconButton(
            icon: Icon(
              Icons.stop_circle_outlined,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () async {
              try {
                await runProvider.interruptRun(_currentRun!.id);
                _refreshRun();
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to abort: $e')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomSheetsButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: getIt<CustomReportProvider>(),
            child: const CustomReportSheetDialog(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: AppRadius.br6,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.layoutDashboard, size: 13, color: AppColors.accent),
            const SizedBox(width: 5),
            Text(
              'Custom Sheets',
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    final isTerminal =
        _currentRun != null && _isTerminalStatus(_currentRun!.status);
    if (!isTerminal) return const SizedBox.shrink();

    return PopupMenuButton<RunExportFormat>(
      enabled: !_exporting,
      tooltip: 'Export',
      onSelected: _exportRun,
      itemBuilder: (context) => RunExportFormat.values
          .map(
            (format) => PopupMenuItem(value: format, child: Text(format.label)),
          )
          .toList(),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: _exporting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              : Icon(LucideIcons.fileDown, color: AppColors.accent, size: 20),
        ),
      ),
    );
  }

  Widget _buildRunInfoCard() {
    if (_loadingRun) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: AppRadius.br8,
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: PilotSkeleton(width: 40, height: 20)),
      );
    }

    if (_currentRun == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: AppRadius.br8,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No run metadata available',
            style: AppTypography.caption,
          ),
        ),
      );
    }

    final status = _currentRun!.status.toUpperCase();
    final statusColor = status == 'COMPLETED'
        ? AppColors.success
        : (status == 'FAILED' || status == 'ABORTED' || status == 'CANCELED'
              ? AppColors.error
              : AppColors.info);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: AppRadius.br8,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Run #${_currentRun!.id}',
                  style: AppTypography.heading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PilotBadge(label: status, color: statusColor, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _InfoBadge(
                label: 'Threads',
                value: _currentRun!.threads.toString(),
              ),
              const SizedBox(width: AppSpacing.xl),
              _InfoBadge(
                label: 'Duration',
                value: _currentRun!.duration != null
                    ? '${_currentRun!.duration}s'
                    : '-',
              ),
              const SizedBox(width: AppSpacing.xl),
              _InfoBadge(
                label: 'Loops',
                value: _currentRun!.loopCount?.toString() ?? '-',
              ),
              const SizedBox(width: AppSpacing.xl),
              _InfoBadge(label: 'Elapsed', value: _formatDuration(_elapsed)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      ],
    );
  }
}
