import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stress_pilot/core/system/backend_launch_args.dart';

void main() {
  test('stores and parses newline separated backend args', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BackendLaunchArgs();

    await service.saveRaw(
      '--application.distributed.enabled=true\n'
      '--spring.data.redis.host=127.0.0.1',
    );

    expect(await service.loadArgs(), [
      '--application.distributed.enabled=true',
      '--spring.data.redis.host=127.0.0.1',
    ]);
  });

  test('trims whitespace and discards blank lines', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BackendLaunchArgs();

    await service.saveRaw(
      '  --application.distributed.enabled=true  \n'
      '\n'
      ' \t \n'
      ' --spring.data.redis.host=127.0.0.1 ',
    );

    expect(await service.loadArgs(), [
      '--application.distributed.enabled=true',
      '--spring.data.redis.host=127.0.0.1',
    ]);
  });

  test('reset clears stored backend args', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BackendLaunchArgs();

    await service.saveRaw('--application.distributed.enabled=true');
    await service.reset();

    expect(await service.loadRaw(), isEmpty);
    expect(await service.loadArgs(), isEmpty);
  });
}
