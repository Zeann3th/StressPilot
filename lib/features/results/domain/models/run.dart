class Run {
  final String id;
  final int flowId;
  final String status;
  final int threads;
  final int? duration;
  final int? loopCount;
  final int rampUpDuration;
  final DateTime startedAt;
  final DateTime? completedAt;

  Run({
    required this.id,
    required this.flowId,
    required this.status,
    required this.threads,
    this.duration,
    this.loopCount,
    required this.rampUpDuration,
    required this.startedAt,
    this.completedAt,
  });

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'].toString(),
      flowId: json['flowId'],
      status: json['status'] ?? '',
      threads: json['threads'] ?? 0,
      duration: json['duration'],
      loopCount: json['loopCount'],
      rampUpDuration: json['rampUpDuration'] ?? 0,
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
