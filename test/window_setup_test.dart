import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/window/window_manager.dart';

void main() {
  group('WindowSetup', () {
    test('uses window_manager lifecycle on desktop targets', () {
      expect(
        WindowSetup.lifecycleBackendFor(TargetPlatform.windows),
        DesktopWindowLifecycleBackend.windowManager,
      );
      expect(
        WindowSetup.lifecycleBackendFor(TargetPlatform.linux),
        DesktopWindowLifecycleBackend.windowManager,
      );
      expect(
        WindowSetup.lifecycleBackendFor(TargetPlatform.macOS),
        DesktopWindowLifecycleBackend.windowManager,
      );
    });

    test(
      'does not initialize a desktop window lifecycle on mobile targets',
      () {
        expect(
          WindowSetup.lifecycleBackendFor(TargetPlatform.android),
          DesktopWindowLifecycleBackend.none,
        );
        expect(
          WindowSetup.lifecycleBackendFor(TargetPlatform.iOS),
          DesktopWindowLifecycleBackend.none,
        );
        expect(
          WindowSetup.lifecycleBackendFor(TargetPlatform.fuchsia),
          DesktopWindowLifecycleBackend.none,
        );
      },
    );

    test('uses the same window size constraints for every desktop target', () {
      final options = WindowSetup.defaultOptions;

      expect(options.minimumSize, const Size(1280, 720));
      expect(options.center, isTrue);
      expect(options.skipTaskbar, isFalse);
      expect(options.title, 'Stress Pilot');
    });
  });
}
