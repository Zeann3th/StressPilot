import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/glow_card.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/animated_counter.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/status_badge.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/pulse_indicator.dart';
import 'package:stress_pilot/core/di/locator.dart';

void main() {
  setUpAll(() => setupLocator());

  testWidgets('GlowCard renders child without glow', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: GlowCard(child: Text('hello'))),
    ));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('GlowCard renders child with glow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GlowCard(glowColor: Colors.blue, child: const Text('glow')),
      ),
    ));
    expect(find.text('glow'), findsOneWidget);
  });

  testWidgets('AnimatedCounter displays formatted final value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnimatedCounter(
          value: 42,
          formatter: (v) => v.toInt().toString(),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('StatusBadge renders label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatusBadge(color: Colors.green, label: 'LIVE'),
      ),
    ));
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('PulseIndicator renders without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: PulseIndicator()),
    ));
    expect(tester.takeException(), isNull);
  });
}
