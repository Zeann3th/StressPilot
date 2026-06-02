import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stress_pilot/core/network/http_client.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';
import '../../domain/repositories/run_repository.dart';

class RunRepositoryImpl implements RunRepository {
  final Dio _dio = HttpClient.getInstance();

  @override
  Future<Run> getLastRun(int flowId) async {
    final response = await _dio.get(
      '/api/v1/runs/last',
      queryParameters: {'flowId': flowId},
    );
    return Run.fromJson(response.data['data']);
  }

  @override
  Future<List<Run>> getRuns({int? flowId}) async {
    final response = await _dio.get(
      '/api/v1/runs',
      queryParameters: {'flowId': flowId},
    );
    return (response.data['data'] as List).map((e) => Run.fromJson(e)).toList();
  }

  @override
  Future<Run> getRun(String runId) async {
    final response = await _dio.get('/api/v1/runs/$runId');
    return Run.fromJson(response.data['data']);
  }

  @override
  Future<File?> exportRun(
    Run run, {
    RunExportFormat format = RunExportFormat.xlsx,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/runs/${run.id}/export',
        queryParameters: {'type': format.apiValue},
        options: Options(
          responseType: ResponseType.bytes,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      final date = run.startedAt.toLocal();

      final dateStr =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_'
          '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}.${date.second.toString().padLeft(2, '0')}';

      final fileName =
          '[Stress Pilot] Detailed report of run ${run.id} $dateStr.${format.extension}';

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Run Report',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [format.extension],
      );

      if (outputFile == null) {
        return null;
      }

      if (!outputFile.toLowerCase().endsWith('.${format.extension}')) {
        outputFile = '$outputFile.${format.extension}';
      }

      final finalFile = File(outputFile);
      await finalFile.writeAsBytes(bytes);
      return finalFile;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> interruptRun(String runId) async {
    await _dio.delete('/api/v1/runs/$runId');
  }

  @override
  Future<File?> exportRunComparison(String runId1, String runId2) async {
    final response = await _dio.get<List<int>>(
      '/api/v1/runs/compare/$runId1..$runId2/export',
      options: Options(
        responseType: ResponseType.bytes,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) return null;

    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}.${now.second.toString().padLeft(2, '0')}';

    final fileName =
        '[Stress Pilot] Comparison report $runId1 vs $runId2 $dateStr.xlsx';

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save Comparison Report',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );

    if (outputFile == null) {
      return null;
    }

    if (!outputFile.toLowerCase().endsWith('.xlsx')) {
      outputFile = '$outputFile.xlsx';
    }

    final finalFile = File(outputFile);
    await finalFile.writeAsBytes(bytes);
    return finalFile;
  }
}
