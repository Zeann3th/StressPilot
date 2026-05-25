import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/system/backend_launch_args.dart';
import 'package:stress_pilot/core/themes/theme_manager.dart';
import 'package:stress_pilot/features/settings/domain/repositories/setting_repository.dart';
import 'package:stress_pilot/features/settings/presentation/provider/setting_provider.dart';
import 'package:stress_pilot/features/settings/presentation/widgets/backend_args_settings_view.dart';

class _FakeSettingRepository implements SettingRepository {
  @override
  Future<Map<String, String>> getAllConfigs() async => {};

  @override
  Future<String?> getConfigValue(String key) async => null;

  @override
  Future<void> setConfigValue({
    required String key,
    required String value,
  }) async {}
}

Future<BackendLaunchArgs> _pumpView(WidgetTester tester) async {
  final backendLaunchArgs = BackendLaunchArgs();
  final provider = SettingProvider(
    _FakeSettingRepository(),
    backendLaunchArgs: backendLaunchArgs,
  );
  await provider.loadBackendArgs();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: Scaffold(body: BackendArgsSettingsView())),
    ),
  );
  await tester.pumpAndSettle();

  return backendLaunchArgs;
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton(() => ThemeManager());
  });

  testWidgets('displays multiline field and example backend args', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _pumpView(tester);

    final textField = tester.widget<TextField>(find.byType(TextField));

    expect(textField.maxLines, greaterThan(1));
    expect(find.text('Backend Launch Arguments'), findsOneWidget);
    expect(
      find.textContaining('--application.distributed.enabled=true'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('--spring.data.redis.host=127.0.0.1'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('--spring.data.redis.port=6379'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('saving persists raw backend args', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final backendLaunchArgs = await _pumpView(tester);

    const rawArgs =
        '--application.distributed.enabled=true\n'
        '--spring.data.redis.host=127.0.0.1';

    await tester.enterText(find.byType(TextField), rawArgs);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    expect(await backendLaunchArgs.loadRaw(), rawArgs);
  });

  testWidgets('reset clears persisted raw backend args', (tester) async {
    SharedPreferences.setMockInitialValues({
      'backend_launch_args_raw': '--application.distributed.enabled=true',
    });
    final backendLaunchArgs = await _pumpView(tester);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    expect(await backendLaunchArgs.loadRaw(), isEmpty);
    expect(find.byType(TextField), findsOneWidget);
  });
}
