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

  test('stores and parses split JVM and application args', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BackendLaunchArgs();

    await service.saveStructured(
      jvmArgsRaw: '-javaagent:/tmp/agent.jar\n-Xmx2g',
      appArgsRaw:
          '--spring.config.additional-location=file:/tmp/app.yaml\n'
          '--spring.data.redis.host=127.0.0.1',
    );

    final options = await service.loadOptions();

    expect(options.jvmArgs, ['-javaagent:/tmp/agent.jar', '-Xmx2g']);
    expect(options.appArgs, [
      '--spring.config.additional-location=file:/tmp/app.yaml',
      '--spring.data.redis.host=127.0.0.1',
    ]);
  });

  test('trims whitespace and discards blank lines', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BackendLaunchArgs();

    await service.saveRaw(
      '  --application.distributed.enabled=true  \n'
      '\n'
      '# ignored comment\n'
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

    await service.saveStructured(
      jvmArgsRaw: '-javaagent:/tmp/agent.jar',
      appArgsRaw: '--application.distributed.enabled=true',
    );
    await service.reset();

    expect(await service.loadRaw(), isEmpty);
    expect(await service.loadJvmRaw(), isEmpty);
    expect(await service.loadAppRaw(), isEmpty);
    expect(await service.loadArgs(), isEmpty);
  });

  test('loads legacy raw args as application args', () async {
    SharedPreferences.setMockInitialValues({
      'backend_launch_args_raw': '--spring.data.redis.host=127.0.0.1',
    });
    final service = BackendLaunchArgs();

    expect(await service.loadAppRaw(), '--spring.data.redis.host=127.0.0.1');
    expect((await service.loadOptions()).appArgs, [
      '--spring.data.redis.host=127.0.0.1',
    ]);
  });
}
