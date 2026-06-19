import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/results/presentation/widgets/run_complete_overlay.dart';
import 'package:stress_pilot/core/di/locator.dart';

void main() {
  setUpAll(() => setupLocator());

  testWidgets('RunCompleteOverlay shows "Run Complete" on success', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RunCompleteOverlay(isSuccess: true)),
    ));
    // Pump to let animations start
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Run Complete'), findsOneWidget);
  });

  testWidgets('RunCompleteOverlay shows "Run Failed" on failure', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RunCompleteOverlay(isSuccess: false)),
    ));
    // Pump to let animations start
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Run Failed'), findsOneWidget);
  });
}
