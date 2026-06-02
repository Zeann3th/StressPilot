import 'dart:io';
import 'package:stress_pilot/features/results/domain/models/run.dart';

enum RunExportFormat {
  xlsx('XLSX', 'XLSX', 'xlsx'),
  html('HTML', 'HTML', 'html');

  const RunExportFormat(this.apiValue, this.label, this.extension);

  final String apiValue;
  final String label;
  final String extension;
}

abstract class RunRepository {
  Future<Run> getLastRun(int flowId);
  Future<List<Run>> getRuns({int? flowId});
  Future<Run> getRun(String runId);
  Future<File?> exportRun(
    Run run, {
    RunExportFormat format = RunExportFormat.xlsx,
  });
  Future<File?> exportRunComparison(String runId1, String runId2);
  Future<void> interruptRun(String runId);
}
