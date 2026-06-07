import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' as wm;

enum DesktopWindowLifecycleBackend { none, windowManager }

class WindowSetup {
  static bool get isSupported =>
      !kIsWeb &&
      lifecycleBackendFor(defaultTargetPlatform) !=
          DesktopWindowLifecycleBackend.none;

  static wm.WindowOptions get defaultOptions => const wm.WindowOptions(
    minimumSize: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: wm.TitleBarStyle.normal,
    title: 'Stress Pilot',
  );

  static DesktopWindowLifecycleBackend lifecycleBackendFor(
    TargetPlatform platform,
  ) {
    return switch (platform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS => DesktopWindowLifecycleBackend.windowManager,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS => DesktopWindowLifecycleBackend.none,
    };
  }

  static Future<void> initialize() async {
    if (!isSupported) {
      return;
    }

    await wm.windowManager.ensureInitialized();
    await wm.windowManager.waitUntilReadyToShow(defaultOptions);
    await wm.windowManager.setResizable(true);
    await wm.windowManager.maximize();
    await wm.windowManager.show();
    await wm.windowManager.focus();
  }
}
