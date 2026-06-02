import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/core/system/backend_launch_args.dart';
import 'package:stress_pilot/features/settings/domain/repositories/setting_repository.dart';
import 'package:stress_pilot/features/settings/presentation/provider/setting_provider.dart';

class _FailingSettingRepository implements SettingRepository {
  _FailingSettingRepository(this.failure);

  final Object failure;

  @override
  Future<Map<String, String>> getAllConfigs() async => {};

  @override
  Future<String?> getConfigValue(String key) async => null;

  @override
  Future<void> setConfigValue({
    required String key,
    required String value,
  }) async {
    throw failure;
  }
}

void main() {
  test('setConfig rethrows repository failures and records error', () async {
    final failure = StateError('persist failed');
    final provider = SettingProvider(
      _FailingSettingRepository(failure),
      backendLaunchArgs: BackendLaunchArgs(),
    );

    await expectLater(
      provider.setConfig('application.distributed.enabled', 'true'),
      throwsA(same(failure)),
    );

    expect(provider.error, failure.toString());
    expect(
      provider.configs,
      isNot(contains('application.distributed.enabled')),
    );
  });
}
