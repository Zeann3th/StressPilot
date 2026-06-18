import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stress_pilot/features/results/presentation/widgets/metrics_card.dart';
import 'package:stress_pilot/core/di/locator.dart';

void main() {
  setUpAll(() => setupLocator());

  testWidgets('MetricsCard shows title', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MetricsCard(
          title: 'RPS',
          numericValue: 142.0,
          formatter: (v) => v.toStringAsFixed(1),
          icon: LucideIcons.gauge,
          color: Colors.green,
        ),
      ),
    ));
    expect(find.text('RPS'), findsOneWidget);
  });

  testWidgets('MetricsCard shows formatted value after animation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MetricsCard(
          title: 'Errors',
          numericValue: 5.0,
          formatter: (v) => v.toInt().toString(),
          icon: LucideIcons.alertTriangle,
          color: Colors.red,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('MetricsCard renders with isActive true', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MetricsCard(
          title: 'Total',
          numericValue: 1000.0,
          formatter: (v) => v.toInt().toString(),
          icon: LucideIcons.hash,
          color: Colors.blue,
          isActive: true,
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
