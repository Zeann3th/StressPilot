import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_sheet.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_element.dart';
import 'package:stress_pilot/features/results/domain/repositories/custom_report_repository.dart';
import 'package:stress_pilot/features/results/presentation/provider/custom_report_provider.dart';

class _FakeRepo implements CustomReportRepository {
  final List<CustomReportSheet> _sheets = [];
  int _nextSheetId = 1;
  int _nextElemId = 1;

  @override
  Future<List<CustomReportSheet>> getSheets() async => List.unmodifiable(_sheets);

  @override
  Future<CustomReportSheet> createSheet({
    required String name,
    required int displayOrder,
  }) async {
    final sheet = CustomReportSheet(
      id: _nextSheetId++,
      name: name,
      displayOrder: displayOrder,
      elements: [],
    );
    _sheets.add(sheet);
    return sheet;
  }

  @override
  Future<CustomReportSheet> updateSheet(int id,
      {String? name, int? displayOrder}) async {
    final idx = _sheets.indexWhere((s) => s.id == id);
    final old = _sheets[idx];
    final updated = CustomReportSheet(
      id: old.id,
      name: name ?? old.name,
      displayOrder: displayOrder ?? old.displayOrder,
      elements: old.elements,
    );
    _sheets[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteSheet(int id) async {
    _sheets.removeWhere((s) => s.id == id);
  }

  @override
  Future<CustomReportElement> createElement(int sheetId,
      {required String name,
      required String type,
      String? config,
      required int displayOrder}) async {
    return CustomReportElement(
      id: _nextElemId++,
      sheetId: sheetId,
      name: name,
      type: type,
      config: config,
      displayOrder: displayOrder,
    );
  }

  @override
  Future<CustomReportElement> updateElement(int sheetId, int elementId,
      {String? name,
      String? type,
      String? config,
      int? displayOrder}) async {
    return CustomReportElement(
      id: elementId,
      sheetId: sheetId,
      name: name ?? 'updated',
      type: type ?? 'STAT',
      config: config,
      displayOrder: displayOrder ?? 0,
    );
  }

  @override
  Future<void> deleteElement(int sheetId, int elementId) async {}
}

void main() {
  late _FakeRepo repo;
  late CustomReportProvider provider;

  setUp(() {
    repo = _FakeRepo();
    provider = CustomReportProvider(repo);
  });

  test('sheets empty on init', () {
    expect(provider.sheets, isEmpty);
  });

  test('loadSheets populates sheets', () async {
    await repo.createSheet(name: 'Sheet A', displayOrder: 0);
    await provider.loadSheets();
    expect(provider.sheets.length, equals(1));
    expect(provider.sheets.first.name, equals('Sheet A'));
  });

  test('createSheet adds to list', () async {
    await provider.createSheet(name: 'New Sheet', displayOrder: 0);
    expect(provider.sheets.length, equals(1));
  });

  test('deleteSheet removes from list', () async {
    await provider.createSheet(name: 'ToDelete', displayOrder: 0);
    final id = provider.sheets.first.id;
    await provider.deleteSheet(id);
    expect(provider.sheets, isEmpty);
  });

  test('isLoading is false when not loading', () {
    expect(provider.isLoading, isFalse);
  });
}
