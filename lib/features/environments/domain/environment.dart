class Environment {
  final int id;
  final int projectId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Environment({
    required this.id,
    required this.projectId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory Environment.fromJson(Map<String, dynamic> json) => Environment(
    id: _toInt(json['id']),
    projectId: _toInt(json['projectId']),
    name: json['name'] ?? 'Environment',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
  );
}
