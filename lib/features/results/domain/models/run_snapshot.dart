import 'dart:convert';

class RunSnapshot {
  final String id;
  final int flowId;
  final String status;
  final int threads;
  final int duration;
  final int rampUpDuration;
  final String startedAt;
  final String completedAt;
  final Map<int, List<Map<String, dynamic>>> metrics;

  RunSnapshot({
    required this.id,
    required this.flowId,
    required this.status,
    required this.threads,
    required this.duration,
    required this.rampUpDuration,
    required this.startedAt,
    required this.completedAt,
    required this.metrics,
  });

  factory RunSnapshot.fromJson(Map<String, dynamic> json) {
    Map<int, List<Map<String, dynamic>>> parsedMetrics = {};
    if (json['metrics'] != null) {
      try {
        final Map<String, dynamic> rawMetrics = jsonDecode(json['metrics']);
        rawMetrics.forEach((key, value) {
          final endpointId = int.tryParse(key) ?? 0;
          final List<dynamic> binsRaw = value;
          final List<Map<String, dynamic>> bins =
              binsRaw.map((e) => e as Map<String, dynamic>).toList();
          parsedMetrics[endpointId] = bins;
        });
      } catch (e) {
        // Fallback
      }
    }

    return RunSnapshot(
      id: json['id'],
      flowId: json['flowId'] ?? 0,
      status: json['status'] ?? '',
      threads: json['threads'] ?? 0,
      duration: json['duration'] ?? 0,
      rampUpDuration: json['rampUpDuration'] ?? 0,
      startedAt: json['startedAt'] ?? '',
      completedAt: json['completedAt'] ?? '',
      metrics: parsedMetrics,
    );
  }
}
