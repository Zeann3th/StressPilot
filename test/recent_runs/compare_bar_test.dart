import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/di/locator.dart';

// Mirrors the _CompareBar widget from recent_runs_page.dart for unit testing
class _TestCompareBar extends StatelessWidget {
  final bool isExporting;
  final int selectedCount;
  final VoidCallback onExport;

  const _TestCompareBar({
    required this.isExporting,
    required this.selectedCount,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: AppRadius.br12,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            lucide.LucideIcons.gitCompare,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Text(
            '$selectedCount of 2 runs selected',
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          PilotButton.primary(
            icon: lucide.LucideIcons.fileSpreadsheet,
            label: isExporting ? 'Exporting...' : 'Export Comparison',
            onPressed: isExporting ? null : onExport,
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(() => setupLocator());

  group('CompareBar', () {
    testWidgets('shows selected count label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCompareBar(
            isExporting: false,
            selectedCount: 1,
            onExport: () {},
          ),
        ),
      ));
      expect(find.text('1 of 2 runs selected'), findsOneWidget);
    });

    testWidgets('shows Export Comparison when not exporting', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCompareBar(
            isExporting: false,
            selectedCount: 2,
            onExport: () {},
          ),
        ),
      ));
      expect(find.text('Export Comparison'), findsOneWidget);
    });

    testWidgets('shows Exporting... label when exporting', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCompareBar(
            isExporting: true,
            selectedCount: 2,
            onExport: () {},
          ),
        ),
      ));
      expect(find.text('Exporting...'), findsOneWidget);
    });

    testWidgets('onExport callback fires when not exporting', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCompareBar(
            isExporting: false,
            selectedCount: 2,
            onExport: () => called = true,
          ),
        ),
      ));
      await tester.tap(find.text('Export Comparison'));
      expect(called, isTrue);
    });

    testWidgets('button is disabled when exporting', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCompareBar(
            isExporting: true,
            selectedCount: 2,
            onExport: () => called = true,
          ),
        ),
      ));
      await tester.tap(find.text('Exporting...'), warnIfMissed: false);
      expect(called, isFalse);
    });
  });
}
