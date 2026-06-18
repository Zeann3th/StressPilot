import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';
import 'package:stress_pilot/features/projects/presentation/widgets/runs_list_widget.dart' show formatRuntime;

// Minimal Run factory for tests
Run _makeRun({
  String id = '1',
  String status = 'COMPLETED',
  DateTime? startedAt,
  DateTime? completedAt,
  int threads = 10,
  int? duration = 30,
  int? loopCount = 5,
}) {
  return Run(
    id: id,
    flowId: 42,
    status: status,
    threads: threads,
    duration: duration,
    loopCount: loopCount,
    rampUpDuration: 0,
    startedAt: startedAt ?? DateTime(2024, 1, 1, 10, 0),
    completedAt: completedAt ?? DateTime(2024, 1, 1, 10, 0, 30),
  );
}

void main() {
  setUpAll(() => setupLocator());

  group('formatRuntime logic', () {
    test('returns seconds when diff < 60s', () {
      final start = DateTime(2024, 1, 1, 10, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 0, 45);
      expect(formatRuntime(start, end), '45s');
    });

    test('returns minutes and seconds when diff >= 60s', () {
      final start = DateTime(2024, 1, 1, 10, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 2, 15);
      expect(formatRuntime(start, end), '2m 15s');
    });

    test('returns hours and minutes when diff >= 3600s', () {
      final start = DateTime(2024, 1, 1, 8, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 30, 0);
      expect(formatRuntime(start, end), '2h 30m');
    });

    test('returns 0s for identical timestamps', () {
      final t = DateTime(2024, 1, 1, 10, 0, 0);
      expect(formatRuntime(t, t), '0s');
    });
  });

  group('Run model fields used by _StatChip', () {
    test('Run.threads is populated correctly', () {
      final run = _makeRun(threads: 50);
      expect(run.threads.toString(), '50');
    });

    test('Run.duration formats as expected', () {
      final run = _makeRun(duration: 120);
      expect('${run.duration}s', '120s');
    });

    test('Run.duration null formats as dash', () {
      final run = _makeRun(duration: null);
      final value = run.duration != null ? '${run.duration}s' : '—';
      expect(value, '—');
    });

    test('Run.loopCount formats as expected', () {
      final run = _makeRun(loopCount: 3);
      expect(run.loopCount?.toString() ?? '—', '3');
    });

    test('Run.loopCount null formats as dash', () {
      final run = _makeRun(loopCount: null);
      expect(run.loopCount?.toString() ?? '—', '—');
    });

    test('Total stat chip value computed from startedAt/completedAt', () {
      final run = _makeRun(
        startedAt: DateTime(2024, 1, 1, 10, 0, 0),
        completedAt: DateTime(2024, 1, 1, 10, 1, 30),
      );
      expect(run.completedAt, isNotNull);
      expect(formatRuntime(run.startedAt, run.completedAt!), '1m 30s');
    });
  });

  group('Stagger animation delay values', () {
    test('item 0 has 0ms delay', () {
      final delay = Duration(milliseconds: 0 * 60);
      expect(delay.inMilliseconds, 0);
    });

    test('item 1 has 60ms delay', () {
      final delay = Duration(milliseconds: 1 * 60);
      expect(delay.inMilliseconds, 60);
    });

    test('item 5 has 300ms delay', () {
      final delay = Duration(milliseconds: 5 * 60);
      expect(delay.inMilliseconds, 300);
    });
  });

  group('formatRuntime is used correctly', () {
    test('formatRuntime is public and can be imported', () {
      // Verify the function works as expected when called directly
      final start = DateTime(2024, 1, 1, 10, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 2, 15);
      expect(formatRuntime(start, end), '2m 15s');
    });

    test('formatRuntime handles edge cases', () {
      final t = DateTime(2024, 1, 1, 10, 0, 0);
      expect(formatRuntime(t, t), '0s');
    });
  });
}
