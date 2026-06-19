import '../models/custom_report_sheet.dart';
import '../models/custom_report_element.dart';

abstract class CustomReportRepository {
  Future<List<CustomReportSheet>> getSheets();
  Future<CustomReportSheet> createSheet({required String name, required int displayOrder});
  Future<CustomReportSheet> updateSheet(int id, {String? name, int? displayOrder});
  Future<void> deleteSheet(int id);

  Future<CustomReportElement> createElement(
    int sheetId, {
    required String name,
    required String type,
    String? config,
    required int displayOrder,
  });
  Future<CustomReportElement> updateElement(
    int sheetId,
    int elementId, {
    String? name,
    String? type,
    String? config,
    int? displayOrder,
  });
  Future<void> deleteElement(int sheetId, int elementId);
}
