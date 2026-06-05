import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/system/process_manager.dart';

void main() {
  test('buildBackendArgs appends custom args after profile', () {
    final args = buildBackendArgs(
      jarPath: 'core/app.jar',
      profile: 'dev',
      jsaPath: 'cache/app.jsa',
      customJvmArgs: ['-javaagent:/tmp/agent.jar'],
      customAppArgs: [
        '--application.distributed.enabled=true',
        '--spring.data.redis.host=127.0.0.1',
      ],
    );

    expect(args, [
      '-javaagent:/tmp/agent.jar',
      '-XX:SharedArchiveFile=cache/app.jsa',
      '-jar',
      'core/app.jar',
      '--spring.profiles.active=dev',
      '--application.distributed.enabled=true',
      '--spring.data.redis.host=127.0.0.1',
    ]);
  });

  test('buildBackendArgs omits shared archive arg when jsaPath is null', () {
    final args = buildBackendArgs(
      jarPath: 'core/app.jar',
      profile: 'prod',
      jsaPath: null,
      customJvmArgs: [],
      customAppArgs: ['--server.port=52000'],
    );

    expect(args, [
      '-jar',
      'core/app.jar',
      '--spring.profiles.active=prod',
      '--server.port=52000',
    ]);
  });

  test('buildBackendArgs preserves custom arg order', () {
    final args = buildBackendArgs(
      jarPath: 'core/app.jar',
      profile: 'dev',
      jsaPath: null,
      customJvmArgs: ['-Xmx2g', '-javaagent:/tmp/agent.jar'],
      customAppArgs: ['--first=1', '--second=2', '--third=3'],
    );

    expect(args.take(2), ['-Xmx2g', '-javaagent:/tmp/agent.jar']);
    expect(args.skip(5), ['--first=1', '--second=2', '--third=3']);
  });
}
