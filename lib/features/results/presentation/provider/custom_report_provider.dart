import 'package:flutter/foundation.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_sheet.dart';
import 'package:stress_pilot/features/results/domain/models/custom_report_element.dart';
import 'package:stress_pilot/features/results/domain/repositories/custom_report_repository.dart';

class CustomReportProvider extends ChangeNotifier {
  final CustomReportRepository _repository;

  List<CustomReportSheet> _sheets = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomReportProvider(this._repository);

  List<CustomReportSheet> get sheets => List.unmodifiable(_sheets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSheets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _sheets = await _repository.getSheets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSheet({
    required String name,
    required int displayOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final sheet = await _repository.createSheet(
        name: name,
        displayOrder: displayOrder,
      );
      _sheets = [..._sheets, sheet];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSheet(
    int id, {
    String? name,
    int? displayOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.updateSheet(
        id,
        name: name,
        displayOrder: displayOrder,
      );
      _sheets = _sheets.map((s) => s.id == id ? updated : s).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSheet(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteSheet(id);
      _sheets = _sheets.where((s) => s.id != id).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomReportElement?> createElement(
    int sheetId, {
    required String name,
    required String type,
    String? config,
    required int displayOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final element = await _repository.createElement(
        sheetId,
        name: name,
        type: type,
        config: config,
        displayOrder: displayOrder,
      );
      await _reloadSheets();
      return element;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateElement(
    int sheetId,
    int elementId, {
    String? name,
    String? type,
    String? config,
    int? displayOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateElement(
        sheetId,
        elementId,
        name: name,
        type: type,
        config: config,
        displayOrder: displayOrder,
      );
      await _reloadSheets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteElement(int sheetId, int elementId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteElement(sheetId, elementId);
      await _reloadSheets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload sheets without toggling isLoading (used internally after mutations).
  /// On failure, keeps the existing sheets and sets a descriptive error message.
  Future<void> _reloadSheets() async {
    try {
      _sheets = await _repository.getSheets();
    } catch (e) {
      _errorMessage = 'Changes saved but could not refresh list: $e';
    }
  }
}
