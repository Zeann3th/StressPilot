import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/shared/domain/models/endpoint.dart';
import 'package:stress_pilot/features/shared/presentation/provider/endpoint_provider.dart';
import 'package:stress_pilot/features/shared/domain/models/flow.dart'
    as flow_domain;
import 'package:stress_pilot/features/shared/presentation/provider/flow_provider.dart';
import 'package:stress_pilot/features/shared/domain/models/run.dart';
import 'package:stress_pilot/features/shared/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/shared/presentation/provider/run_provider.dart';
import 'package:stress_pilot/features/workspace/presentation/provider/canvas_provider.dart';
import 'package:stress_pilot/features/workspace/presentation/provider/workspace_tab_provider.dart';
import 'package:stress_pilot/features/workspace/presentation/widgets/workspace_canvas.dart';

class _FakeEndpointProvider extends EndpointProvider {
  List<Endpoint> _items = [];

  @override
  List<Endpoint> get endpoints => _items;

  void publish(List<Endpoint> endpoints) {
    _items = endpoints;
    notifyListeners();
  }
}

class _FakeFlowProvider extends FlowProvider {
  final flow_domain.Flow flow;
  int? clearedDryRunFlowId;

  _FakeFlowProvider(this.flow);

  @override
  Future<flow_domain.Flow> getFlow(int flowId) async => flow;

  @override
  void clearDryRunState(int flowId) {
    clearedDryRunFlowId = flowId;
    notifyListeners();
  }
}

class _NoopRunRepository implements RunRepository {
  @override
  Future<File?> exportRun(
    Run run, {
    RunExportFormat format = RunExportFormat.xlsx,
  }) async => null;

  @override
  Future<File?> exportRunComparison(String runId1, String runId2) async => null;

  @override
  Future<Run> getLastRun(int flowId) => throw UnimplementedError();

  @override
  Future<Run> getRun(String runId) => throw UnimplementedError();

  @override
  Future<List<Run>> getRuns({int? flowId}) async => [];

  @override
  Future<void> interruptRun(String runId) async {}
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  testWidgets('hydrates endpoint node labels when endpoints load later', (
    tester,
  ) async {
    final endpointProvider = _FakeEndpointProvider();
    final flowProvider = _FakeFlowProvider(
      flow_domain.Flow(
        id: 7,
        name: 'Checkout',
        type: 'DEFAULT',
        projectId: 1,
        steps: [
          flow_domain.FlowStep(
            id: 'step-1',
            type: 'ENDPOINT',
            endpointId: 42,
            preProcessor: const {
              'location': {'x': 3800.0, 'y': 3800.0},
            },
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CanvasProvider>(
            create: (_) => CanvasProvider(),
          ),
          ChangeNotifierProvider<FlowProvider>.value(value: flowProvider),
          ChangeNotifierProvider<EndpointProvider>.value(
            value: endpointProvider,
          ),
          ChangeNotifierProvider<RunProvider>(
            create: (_) => RunProvider(_NoopRunRepository()),
          ),
          ChangeNotifierProvider<WorkspaceTabProvider>(
            create: (_) => WorkspaceTabProvider(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WorkspaceCanvas(
              selectedFlow: flow_domain.Flow(
                id: 7,
                name: 'Checkout',
                type: 'DEFAULT',
                projectId: 1,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Endpoint'), findsOneWidget);
    expect(find.text('Create Order'), findsNothing);

    endpointProvider.publish([
      Endpoint(
        id: 42,
        name: 'Create Order',
        type: 'HTTP',
        url: '/api/orders',
        httpMethod: 'POST',
        projectId: 1,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Create Order'), findsOneWidget);
    expect(find.text('Endpoint'), findsNothing);
  });

  testWidgets('toolbar can reset dry run state for the active flow', (
    tester,
  ) async {
    final endpointProvider = _FakeEndpointProvider();
    final flowProvider = _FakeFlowProvider(
      flow_domain.Flow(
        id: 7,
        name: 'Checkout',
        type: 'DEFAULT',
        projectId: 1,
        steps: const [],
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CanvasProvider>(
            create: (_) => CanvasProvider(),
          ),
          ChangeNotifierProvider<FlowProvider>.value(value: flowProvider),
          ChangeNotifierProvider<EndpointProvider>.value(
            value: endpointProvider,
          ),
          ChangeNotifierProvider<RunProvider>(
            create: (_) => RunProvider(_NoopRunRepository()),
          ),
          ChangeNotifierProvider<WorkspaceTabProvider>(
            create: (_) => WorkspaceTabProvider(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WorkspaceCanvas(
              selectedFlow: flow_domain.Flow(
                id: 7,
                name: 'Checkout',
                type: 'DEFAULT',
                projectId: 1,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byTooltip('Reset Dry Run State'));
    await tester.pump();

    expect(flowProvider.clearedDryRunFlowId, 7);
  });
}
