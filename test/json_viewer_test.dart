import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/endpoints/presentation/widgets/json_viewer.dart';

void main() {
  Map<String, dynamic> manyMatchesJson() {
    return {
      for (var i = 0; i < 200; i++) 'key$i': 'needle value $i',
    };
  }

  testWidgets(
    'only the active match gets a dedicated highlight widget, not every match',
    (tester) async {
      int? reportedCount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonViewer(
              json: manyMatchesJson(),
              searchQuery: 'needle',
              activeMatchIndex: 2,
              onMatchesCountChanged: (c) => reportedCount = c,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(reportedCount, 200);
      expect(find.byType(Container), findsOneWidget);
    },
  );

  testWidgets('reports zero matches when search query is empty', (
    tester,
  ) async {
    int? reportedCount;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonViewer(
            json: manyMatchesJson(),
            searchQuery: '',
            onMatchesCountChanged: (c) => reportedCount = c,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(reportedCount, 0);
    expect(find.byType(Container), findsNothing);
  });
}
