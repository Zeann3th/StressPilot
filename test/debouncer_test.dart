import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/utils/debouncer.dart';

void main() {
  test('coalesces rapid calls into a single trailing invocation', () async {
    final debouncer = Debouncer(const Duration(milliseconds: 30));
    var calls = 0;

    debouncer.run(() => calls++);
    debouncer.run(() => calls++);
    debouncer.run(() => calls++);

    expect(calls, 0);
    await Future.delayed(const Duration(milliseconds: 60));
    expect(calls, 1);

    debouncer.dispose();
  });

  test('dispose cancels a pending call', () async {
    final debouncer = Debouncer(const Duration(milliseconds: 20));
    var calls = 0;

    debouncer.run(() => calls++);
    debouncer.dispose();

    await Future.delayed(const Duration(milliseconds: 40));
    expect(calls, 0);
  });
}
