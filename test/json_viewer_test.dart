import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/endpoints/presentation/widgets/json_viewer.dart';

void main() {
  testWidgets('does not reformat static json when only search state changes', (
    tester,
  ) async {
    var formatCalls = 0;
    final json = {
      'items': ['alpha', 'beta', 'alphabet'],
      'meta': {'count': 3},
    };

    Widget buildViewer({required String query, required int activeIndex}) {
      return MaterialApp(
        home: Scaffold(
          body: JsonViewer(
            json: json,
            searchQuery: query,
            activeMatchIndex: activeIndex,
            jsonFormatter: (value) {
              formatCalls++;
              return const JsonEncoder.withIndent('  ').convert(value);
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildViewer(query: 'alpha', activeIndex: 0));
    expect(formatCalls, 1);

    await tester.pumpWidget(buildViewer(query: 'alpha', activeIndex: 1));
    expect(formatCalls, 1);

    await tester.pumpWidget(buildViewer(query: 'beta', activeIndex: 0));
    expect(formatCalls, 1);
  });

  testWidgets('scrolls to first match when the search query changes', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    final json = {
      for (var i = 0; i < 80; i++) 'field_$i': 'value_$i',
      'target': 'needle',
    };

    Widget buildViewer({required String query}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 120,
            child: SingleChildScrollView(
              controller: scrollController,
              child: JsonViewer(
                json: json,
                searchQuery: query,
                activeMatchIndex: 0,
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildViewer(query: ''));
    expect(scrollController.offset, 0);

    await tester.pumpWidget(buildViewer(query: 'needle'));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
  });
}
