import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/endpoints/presentation/widgets/editor/endpoint_editor_tabs.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  testWidgets('configuration tab shows backend-correct SpEL guidance', (
    tester,
  ) async {
    late TabController controller;
    final successConditionController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 4,
          child: Builder(
            builder: (context) {
              controller = DefaultTabController.of(context);
              controller.index = 3;
              return Scaffold(
                body: EndpointEditorTabs(
                  tabController: controller,
                  params: const {},
                  headers: const {},
                  body: '{}',
                  successConditionController: successConditionController,
                  variables: const {'tenantId': 'demo'},
                  onParamsChanged: (_) {},
                  onHeadersChanged: (_) {},
                  onBodyChanged: (_) {},
                  onVariablesChanged: (_) {},
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining("statusCode == 200 && data['status'] == 'OK'"),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Evaluated against the response object: statusCode, success, message, responseTimeMs, data, rawResponse.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Run Variables'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Sent in the run payload and merged over active environment variables',
      ),
      findsOneWidget,
    );

    successConditionController.dispose();
  });
}
