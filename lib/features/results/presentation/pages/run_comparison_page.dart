import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:fl_chart/fl_chart.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/features/results/domain/models/run_snapshot.dart';
import 'package:stress_pilot/features/results/domain/repositories/run_repository.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';
import 'package:dio/dio.dart';
import 'package:stress_pilot/core/navigation/app_router.dart';

class RunComparisonPage extends StatefulWidget {
  final String runId1;
  final String runId2;

  const RunComparisonPage({
    super.key,
    required this.runId1,
    required this.runId2,
  });

  @override
  State<RunComparisonPage> createState() => _RunComparisonPageState();
}

class _RunComparisonPageState extends State<RunComparisonPage> {
  late Future<List<RunSnapshot>> _comparisonFuture;

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  void _loadComparison() {
    setState(() {
      _comparisonFuture = getIt<RunRepository>().compareSnapshots(
        widget.runId1,
        widget.runId2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseBackground,
      body: Column(
        children: [
          FleetPageBar(
            title: 'Comparison: ${widget.runId1} vs ${widget.runId2}',
            showBack: true,
          ),
          Expanded(
            child: FutureBuilder<List<RunSnapshot>>(
              future: _comparisonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                final data = snapshot.data!;
                if (data.length < 2) {
                  return const Center(
                    child: Text("Insufficient data for comparison"),
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _RunSnapshotView(snapshot: data[0])),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                    Expanded(child: _RunSnapshotView(snapshot: data[1])),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    bool isMissingSnapshot = false;
    if (error is DioException) {
      if (error.response?.statusCode == 404) {
        isMissingSnapshot = true;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(lucide.LucideIcons.alertTriangle, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            isMissingSnapshot
                ? 'Missing Run Snapshot'
                : 'Error loading comparison',
            style: ShadTheme.of(context).textTheme.h3,
          ),
          const SizedBox(height: 8),
          Text(
            isMissingSnapshot
                ? 'One or both runs do not have a snapshot yet.'
                : error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          if (isMissingSnapshot) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShadButton(
                  onPressed: () => _triggerSnapshot(widget.runId1),
                  child: Text('Trigger Snapshot for ${widget.runId1}'),
                ),
                const SizedBox(width: 16),
                ShadButton(
                  onPressed: () => _triggerSnapshot(widget.runId2),
                  child: Text('Trigger Snapshot for ${widget.runId2}'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ShadButton.outline(
            onPressed: _loadComparison,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSnapshot(String runId) async {
    try {
      await getIt<RunRepository>().triggerSnapshot(runId);
      if (mounted) {
        AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Snapshot triggered for $runId'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppNavigator.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Failed to trigger snapshot: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _RunSnapshotView extends StatelessWidget {
  final RunSnapshot snapshot;

  const _RunSnapshotView({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadata(context),
          const SizedBox(height: 32),
          Text('Metrics by Endpoint', style: ShadTheme.of(context).textTheme.h4),
          const SizedBox(height: 16),
          if (snapshot.metrics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No metrics available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...snapshot.metrics.entries.map((entry) {
              return _buildEndpointMetrics(context, entry.key, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return ShadCard(
      title: const Text('Run Metadata'),
      child: Column(
        children: [
          _buildInfoRow('Run ID', snapshot.id),
          _buildInfoRow('Threads', snapshot.threads.toString()),
          _buildInfoRow('Duration', '${snapshot.duration}s'),
          _buildInfoRow('Ramp-up', '${snapshot.rampUpDuration}s'),
          _buildInfoRow('Status', snapshot.status),
          _buildInfoRow('Started', snapshot.startedAt),
          _buildInfoRow('Completed', snapshot.completedAt),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _buildEndpointMetrics(
    BuildContext context,
    int endpointId,
    List<Map<String, dynamic>> bins,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: ShadCard(
        title: Text('Endpoint ID: $endpointId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Avg Response Time (ms) per bin', style: AppTypography.label),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: bins.asMap().entries.map((entry) {
                    final bin = entry.value;
                    final avgTime =
                        (bin['avg_response_time'] as num?)?.toDouble() ?? 0.0;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: avgTime,
                          color: AppColors.accent,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: AppTypography.caption,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTypography.caption,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => FlLine(color: AppColors.divider, strokeWidth: 1),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.elevatedSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(2)} ms',
                          AppTypography.bodyMd,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
