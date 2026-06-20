import 'package:dio/dio.dart';
import 'package:stress_pilot/core/network/http_client.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_sheet.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_element.dart';
import 'package:stress_pilot/features/results/domain/repositories/custom_report_repository.dart';

class CustomReportRepositoryImpl implements CustomReportRepository {
  final Dio _dio = HttpClient.getInstance();

  @override
  Future<List<CustomReportSheet>> getSheets() async {
    final response = await _dio.get('/api/v1/report-sheets');
    final raw = response.data['data'];
    if (raw == null) return [];
    final List<dynamic> data = raw as List<dynamic>;
    return data
        .map((e) => CustomReportSheet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CustomReportSheet> createSheet({
    required String name,
    required int displayOrder,
  }) async {
    final response = await _dio.post('/api/v1/report-sheets',
        data: {'name': name, 'displayOrder': displayOrder});
    return CustomReportSheet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CustomReportSheet> updateSheet(int id,
      {String? name, int? displayOrder}) async {
    final response = await _dio.patch('/api/v1/report-sheets/$id',
        data: {
          'name': ?name,
          'displayOrder': ?displayOrder,
        });
    return CustomReportSheet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSheet(int id) async {
    await _dio.delete('/api/v1/report-sheets/$id');
  }

  @override
  Future<CustomReportElement> createElement(
    int sheetId, {
    required String name,
    required String type,
    String? config,
    required int displayOrder,
  }) async {
    final response = await _dio.post('/api/v1/report-sheets/$sheetId/elements',
        data: {
          'name': name,
          'type': type,
          'config': ?config,
          'displayOrder': displayOrder,
        });
    return CustomReportElement.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CustomReportElement> updateElement(
    int sheetId,
    int elementId, {
    String? name,
    String? type,
    String? config,
    int? displayOrder,
  }) async {
    final response = await _dio.patch(
        '/api/v1/report-sheets/$sheetId/elements/$elementId',
        data: {
          'name': ?name,
          'type': ?type,
          'config': ?config,
          'displayOrder': ?displayOrder,
        });
    return CustomReportElement.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteElement(int sheetId, int elementId) async {
    await _dio.delete('/api/v1/report-sheets/$sheetId/elements/$elementId');
  }
}
