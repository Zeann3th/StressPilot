class CustomReportElement {
  final int id;
  final int sheetId;
  final String name;
  final String type; // LINE | BAR | PIE | STAT
  final String? config;
  final int displayOrder;

  const CustomReportElement({
    required this.id,
    required this.sheetId,
    required this.name,
    required this.type,
    this.config,
    required this.displayOrder,
  });

  factory CustomReportElement.fromJson(Map<String, dynamic> json) =>
      CustomReportElement(
        id: json['id'] as int,
        sheetId: json['sheetId'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        config: json['config'] as String?,
        displayOrder: json['displayOrder'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sheetId': sheetId,
        'name': name,
        'type': type,
        'config': config,
        'displayOrder': displayOrder,
      };
}
