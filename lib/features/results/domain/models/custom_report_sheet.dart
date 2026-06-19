import 'custom_report_element.dart';

class CustomReportSheet {
  final int id;
  final String name;
  final int displayOrder;
  final List<CustomReportElement> elements;

  const CustomReportSheet({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.elements,
  });

  factory CustomReportSheet.fromJson(Map<String, dynamic> json) =>
      CustomReportSheet(
        id: json['id'] as int,
        name: json['name'] as String,
        displayOrder: json['displayOrder'] as int? ?? 0,
        elements: (json['elements'] as List<dynamic>? ?? [])
            .map((e) => CustomReportElement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
