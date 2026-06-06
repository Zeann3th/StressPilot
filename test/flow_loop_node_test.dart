import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/projects/presentation/widgets/node_configuration_dialog.dart';
import 'package:stress_pilot/core/input/keymap_provider.dart';
import 'package:stress_pilot/features/projects/domain/models/flow.dart';
import 'package:stress_pilot/features/workspace/domain/models/canvas.dart';
import 'package:stress_pilot/features/workspace/presentation/provider/canvas_provider.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  test('canvas provider serializes and rebuilds loop nodes', () {
    final provider = CanvasProvider();

    provider.addNode(
      CanvasNode(
        id: 'loop-1',
        type: FlowNodeType.loop,
        position: const Offset(100, 200),
        data: const {
          'name': 'Answer Questions',
          'preProcessor': {
            'loop': {
              'source': 'questions',
              'item': 'question',
              'index': 'question_index',
              'body': 'save-answer',
            },
          },
        },
      ),
    );
    provider.addNode(
      CanvasNode(
        id: 'save-answer',
        type: FlowNodeType.endpoint,
        position: const Offset(300, 200),
        data: const {
          'id': 1,
          'name': 'Save Answer',
          'type': 'HTTP',
          'method': 'POST',
        },
      ),
    );
    provider.addNode(
      CanvasNode(
        id: 'submit',
        type: FlowNodeType.endpoint,
        position: const Offset(500, 200),
        data: const {
          'id': 2,
          'name': 'Submit',
          'type': 'HTTP',
          'method': 'POST',
        },
      ),
    );
    provider.setCanvasMode(CanvasMode.connect);
    provider.selectSourceNode('loop-1', 'body');
    provider.connectToTarget('save-answer');
    provider.selectSourceNode('loop-1');
    provider.connectToTarget('submit');

    final steps = provider.generateFlowConfiguration();
    final loopStep = steps.firstWhere((step) => step.id == 'loop-1');

    expect(loopStep.type, 'LOOP');
    expect(loopStep.nextIfTrue, 'submit');
    expect(loopStep.preProcessor?['loop']['source'], 'questions');
    expect(loopStep.preProcessor?['loop']['body'], 'save-answer');

    provider.rebuildFromSteps([
      FlowStep(
        id: 'loop-1',
        type: 'LOOP',
        nextIfTrue: 'submit',
        preProcessor: loopStep.preProcessor,
      ),
      FlowStep(
        id: 'save-answer',
        type: 'ENDPOINT',
        endpointId: 1,
        endpointName: 'Save Answer',
      ),
      FlowStep(
        id: 'submit',
        type: 'ENDPOINT',
        endpointId: 2,
        endpointName: 'Submit',
      ),
    ]);

    expect(provider.nodes.first.type, FlowNodeType.loop);
    expect(
      provider.nodes.first.data['preProcessor']['loop']['item'],
      'question',
    );
    expect(
      provider.connections.any(
        (connection) =>
            connection.sourceNodeId == 'loop-1' &&
            connection.targetNodeId == 'save-answer' &&
            connection.sourceHandle == 'body',
      ),
      isTrue,
    );
  });

  test('keymap duplicate lookup ignores the currently edited action', () async {
    final provider = KeymapProvider();
    provider.replaceKeymapForTest({
      'flow.run': 'Control+R',
      'flow.save': 'Control+S',
    });

    expect(
      provider.findActionUsingShortcut('Control+R', exceptActionId: 'flow.run'),
      isNull,
    );
    expect(
      provider.findActionUsingShortcut(
        'Control+R',
        exceptActionId: 'flow.save',
      ),
      'flow.run',
    );
  });

  testWidgets('loop configuration can select a body node by label', (
    tester,
  ) async {
    final loopNode = CanvasNode(
      id: 'loop-1',
      type: FlowNodeType.loop,
      position: const Offset(0, 0),
      data: const {
        'name': 'Question Loop',
        'preProcessor': {
          'loop': {'source': 'questions'},
        },
      },
    );
    final bodyNode = CanvasNode(
      id: 'save-answer',
      type: FlowNodeType.endpoint,
      position: const Offset(200, 0),
      data: const {'id': 1, 'name': 'Save Answer', 'type': 'HTTP'},
    );

    Map<String, dynamic>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (_) => NodeConfigurationDialog(
                  node: loopNode,
                  availableNodes: [loopNode, bodyNode],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flow Control'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('No body selected'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Answer').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(result?['preProcessor']['loop']['body'], 'save-answer');
  });
}
