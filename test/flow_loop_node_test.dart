import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/workspace/presentation/widgets/node_configuration_dialog.dart';
import 'package:stress_pilot/core/input/keymap_provider.dart';
import 'package:stress_pilot/features/shared/domain/models/flow.dart';
import 'package:stress_pilot/features/workspace/domain/models/canvas.dart';
import 'package:stress_pilot/features/workspace/presentation/provider/canvas_provider.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  test('canvas provider expands and rebuilds endpoint-owned loops', () {
    final provider = CanvasProvider();

    provider.addNode(
      CanvasNode(
        id: 'start',
        type: FlowNodeType.start,
        position: const Offset(100, 200),
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
          'preProcessor': {
            'loop_enabled': true,
            'loop': {
              'source': 'questions',
              'item': 'question',
              'index': 'question_index',
            },
          },
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
    provider.selectSourceNode('start');
    provider.connectToTarget('save-answer');
    provider.selectSourceNode('save-answer');
    provider.connectToTarget('submit');

    final steps = provider.generateFlowConfiguration();
    final startStep = steps.firstWhere((step) => step.id == 'start');
    final loopStep = steps.firstWhere((step) => step.id == 'save-answer__loop');
    final endpointStep = steps.firstWhere((step) => step.id == 'save-answer');

    expect(startStep.nextIfTrue, 'save-answer__loop');
    expect(loopStep.type, 'LOOP');
    expect(loopStep.nextIfTrue, 'submit');
    expect(loopStep.preProcessor?['loop']['source'], 'questions');
    expect(loopStep.preProcessor?['loop']['body'], 'save-answer');
    expect(endpointStep.nextIfTrue, 'save-answer__loop');
    expect(endpointStep.preProcessor?['loop_enabled'], isNull);
    expect(endpointStep.preProcessor?['loop'], isNull);

    provider.rebuildFromSteps([
      FlowStep(id: 'start', type: 'START', nextIfTrue: 'save-answer__loop'),
      FlowStep(
        id: 'save-answer__loop',
        type: 'LOOP',
        nextIfTrue: 'submit',
        preProcessor: loopStep.preProcessor,
      ),
      FlowStep(
        id: 'save-answer',
        type: 'ENDPOINT',
        endpointId: 1,
        endpointName: 'Save Answer',
        nextIfTrue: 'save-answer__loop',
        preProcessor: endpointStep.preProcessor,
      ),
      FlowStep(
        id: 'submit',
        type: 'ENDPOINT',
        endpointId: 2,
        endpointName: 'Submit',
      ),
    ]);

    final rebuiltEndpoint = provider.nodes.firstWhere(
      (node) => node.id == 'save-answer',
    );
    expect(rebuiltEndpoint.type, FlowNodeType.endpoint);
    expect(rebuiltEndpoint.data['preProcessor']['loop_enabled'], isTrue);
    expect(rebuiltEndpoint.data['preProcessor']['loop']['item'], 'question');
    expect(
      provider.connections.any(
        (connection) =>
            connection.sourceNodeId == 'start' &&
            connection.targetNodeId == 'save-answer',
      ),
      isTrue,
    );
    expect(
      provider.connections.any(
        (connection) =>
            connection.sourceNodeId == 'save-answer' &&
            connection.targetNodeId == 'submit',
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

  testWidgets('endpoint dialog preserves loop mode config', (tester) async {
    final endpointNode = CanvasNode(
      id: 'save-answer',
      type: FlowNodeType.endpoint,
      position: const Offset(0, 0),
      data: const {
        'name': 'Save Answer',
        'type': 'HTTP',
        'preProcessor': {
          'loop_enabled': true,
          'loop': {'source': 'questions', 'item': 'question'},
        },
      },
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
                  node: endpointNode,
                  availableNodes: [endpointNode],
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
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(result?['preProcessor']['loop_enabled'], isTrue);
    expect(result?['preProcessor']['loop']['source'], 'questions');
  });
}
