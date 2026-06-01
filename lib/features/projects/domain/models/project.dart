class Project {
  final int id;
  final String name;
  final String description;
  final int environmentId;
  final int activeEnvironmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.environmentId,
    int? activeEnvironmentId,
    required this.createdAt,
    required this.updatedAt,
  }) : activeEnvironmentId = activeEnvironmentId ?? environmentId;

  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    final activeEnvironmentId = _toInt(
      json['activeEnvironmentId'] ?? json['environmentId'],
    );
    return Project(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      environmentId: activeEnvironmentId,
      activeEnvironmentId: activeEnvironmentId,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'environmentId': environmentId,
    'activeEnvironmentId': activeEnvironmentId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
