import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/results/presentation/provider/results_provider.dart';
import 'package:stress_pilot/features/results/presentation/widgets/realtime_chart.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  testWidgets('run charts pin y axis to zero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 600,
          height: 400,
          child: RealtimeChart(
            title: 'Response Time (ms)',
            color: Colors.orange,
            data: [FlSpotData(x: 1, y: 5002), FlSpotData(x: 2, y: 5007)],
          ),
        ),
      ),
    );

    final chart = tester.widget<LineChart>(find.byType(LineChart));

    expect(chart.data.minY, 0);
  });
}
