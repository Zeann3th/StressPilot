import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/endpoints/domain/models/endpoint.dart';
import 'package:stress_pilot/features/endpoints/presentation/provider/endpoint_provider.dart';
import 'package:stress_pilot/features/projects/domain/models/flow.dart'
    as flow_domain;
import 'package:stress_pilot/features/projects/presentation/provider/flow_provider.dart';
import 'package:stress_pilot/features/projects/presentation/provider/project_provider.dart';
import 'package:stress_pilot/features/results/domain/models/run.dart';
import 'package:stress_pilot/features/results/domain/repositories/run_repository.dart';
import 'package:stress_pilot/features/results/presentation/provider/run_provider.dart';
import 'package:stress_pilot/features/workspace/presentation/provider/workspace_tab_provider.dart';
import 'package:stress_pilot/features/workspace/presentation/widgets/workspace_sidebar.dart';

class _LoadingEndpointProvider extends EndpointProvider {
  @override
  List<Endpoint> get endpoints => const [];

  @override
  bool get isLoading => true;
}

class _LoadingFlowProvider extends FlowProvider {
  @override
  List<flow_domain.Flow> get flows => const [];

  @override
  bool get isLoading => true;
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

  testWidgets('workspace sidebar loading rows keep a right inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EndpointProvider>(
            create: (_) => _LoadingEndpointProvider(),
          ),
          ChangeNotifierProvider<FlowProvider>(
            create: (_) => _LoadingFlowProvider(),
          ),
          ChangeNotifierProvider<ProjectProvider>(
            create: (_) => ProjectProvider(),
          ),
          ChangeNotifierProvider<WorkspaceTabProvider>(
            create: (_) => WorkspaceTabProvider(),
          ),
          ChangeNotifierProvider<RunProvider>(
            create: (_) => RunProvider(_NoopRunRepository()),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 270,
              child: WorkspaceSidebar(onCollapse: () {}),
            ),
          ),
        ),
      ),
    );

    final sidebarRight = tester.getRect(find.byType(WorkspaceSidebar)).right;
    final firstSkeletonRight = tester
        .getRect(find.byType(PilotSkeleton).first)
        .right;

    expect(sidebarRight - firstSkeletonRight, greaterThanOrEqualTo(8));
  });

  testWidgets('pilot input prefix icon is vertically aligned with text', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Search');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: PilotInput(
                controller: controller,
                prefixIcon: LucideIcons.search,
              ),
            ),
          ),
        ),
      ),
    );

    final iconCenter = tester.getCenter(find.byIcon(LucideIcons.search));
    final textCenter = tester.getCenter(find.byType(EditableText));

    expect(
      (iconCenter.dy - textCenter.dy).abs(),
      lessThanOrEqualTo(1.0),
      reason: 'iconCenter=$iconCenter textCenter=$textCenter',
    );
  });
}
