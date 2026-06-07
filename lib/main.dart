import 'package:flutter/material.dart';
import 'package:stress_pilot/core/app_root.dart';
import 'package:stress_pilot/core/di/locator.dart';
import 'package:stress_pilot/core/system/process_manager.dart';
import 'package:stress_pilot/core/system/shutdown_handler.dart';
import 'package:stress_pilot/core/system/app_error_boundary.dart';
import 'package:stress_pilot/core/window/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowSetup.initialize();

  await localNotifier.setup(
    appName: 'Stress Pilot',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  setupDependencies();

  final shutdownHandler = ShutdownHandler(getIt<ProcessManager>());
  await shutdownHandler.setup();

  runApp(const AppErrorBoundary(child: AppRoot()));
}
