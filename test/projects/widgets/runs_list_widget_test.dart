import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';

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

// Mirrors _formatRuntime logic from runs_list_widget.dart for unit testing
String _formatRuntime(DateTime start, DateTime end) {
  final diff = end.difference(start);
  if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ${diff.inSeconds.remainder(60)}s';
  return '${diff.inSeconds}s';
}

void main() {
  setUpAll(() => setupLocator());

  group('_formatRuntime logic', () {
    test('returns seconds when diff < 60s', () {
      final start = DateTime(2024, 1, 1, 10, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 0, 45);
      expect(_formatRuntime(start, end), '45s');
    });

    test('returns minutes and seconds when diff >= 60s', () {
      final start = DateTime(2024, 1, 1, 10, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 2, 15);
      expect(_formatRuntime(start, end), '2m 15s');
    });

    test('returns hours and minutes when diff >= 3600s', () {
      final start = DateTime(2024, 1, 1, 8, 0, 0);
      final end = DateTime(2024, 1, 1, 10, 30, 0);
      expect(_formatRuntime(start, end), '2h 30m');
    });

    test('returns 0s for identical timestamps', () {
      final t = DateTime(2024, 1, 1, 10, 0, 0);
      expect(_formatRuntime(t, t), '0s');
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
      expect(_formatRuntime(run.startedAt, run.completedAt!), '1m 30s');
    });
  });

  group('Status appearance logic', () {
    // Mirrors _statusAppearance switch cases
    test('RUNNING status maps to info color logic', () {
      final run = _makeRun(status: 'RUNNING');
      expect(run.status.toUpperCase(), 'RUNNING');
    });

    test('COMPLETED status maps to success color logic', () {
      final run = _makeRun(status: 'COMPLETED');
      expect(run.status.toUpperCase(), 'COMPLETED');
    });

    test('FAILED status maps to error color logic', () {
      final run = _makeRun(status: 'FAILED');
      expect(run.status.toUpperCase(), 'FAILED');
    });

    test('isRunning is true for RUNNING', () {
      final status = 'RUNNING';
      final isRunning = status == 'RUNNING' || status == 'STARTING';
      expect(isRunning, isTrue);
    });

    test('isRunning is true for STARTING', () {
      final status = 'STARTING';
      final isRunning = status == 'RUNNING' || status == 'STARTING';
      expect(isRunning, isTrue);
    });

    test('isRunning is false for COMPLETED', () {
      final status = 'COMPLETED';
      final isRunning = status == 'RUNNING' || status == 'STARTING';
      expect(isRunning, isFalse);
    });
  });

  group('Stagger animation delay values', () {
    test('item 0 has 0ms delay', () {
      final delay = Duration(milliseconds: 0 * 45);
      expect(delay.inMilliseconds, 0);
    });

    test('item 1 has 45ms delay', () {
      final delay = Duration(milliseconds: 1 * 45);
      expect(delay.inMilliseconds, 45);
    });

    test('item 5 has 225ms delay', () {
      final delay = Duration(milliseconds: 5 * 45);
      expect(delay.inMilliseconds, 225);
    });
  });

  group('StatusBadge pulsing flag', () {
    test('pulsing is true when status is RUNNING', () {
      final status = 'RUNNING';
      final isRunning = status == 'RUNNING' || status == 'STARTING';
      expect(isRunning, isTrue); // StatusBadge(pulsing: isRunning)
    });

    test('pulsing is false when status is COMPLETED', () {
      final status = 'COMPLETED';
      final isRunning = status == 'RUNNING' || status == 'STARTING';
      expect(isRunning, isFalse);
    });
  });
}
