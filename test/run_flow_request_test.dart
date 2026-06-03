import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/projects/domain/models/flow.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';

void main() {
  test('run flow request sends null stop conditions when fields are blank', () {
    final request = RunFlowRequest(
      threads: 1,
      totalDuration: null,
      loopCount: null,
      rampUpDuration: 0,
    );

    expect(request.toJson()['totalDuration'], isNull);
    expect(request.toJson()['loopCount'], isNull);
  });

  test('run model preserves nullable duration and loop count', () {
    final run = Run.fromJson({
      'id': 'run-1',
      'flowId': 7,
      'status': 'COMPLETED',
      'threads': 2,
      'duration': null,
      'loopCount': 5,
      'rampUpDuration': 0,
      'startedAt': '2026-06-03T20:00:00',
      'completedAt': '2026-06-03T20:00:05',
    });

    expect(run.duration, isNull);
    expect(run.loopCount, 5);
  });
}
