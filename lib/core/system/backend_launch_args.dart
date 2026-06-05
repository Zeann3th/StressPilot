import 'package:shared_preferences/shared_preferences.dart';

class BackendLaunchOptions {
  final List<String> jvmArgs;
  final List<String> appArgs;

  const BackendLaunchOptions({required this.jvmArgs, required this.appArgs});
}

class BackendLaunchArgs {
  static const String _rawKey = 'backend_launch_args_raw';
  static const String _jvmRawKey = 'backend_launch_jvm_args_raw';
  static const String _appRawKey = 'backend_launch_app_args_raw';

  Future<String> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyRaw = prefs.getString(_rawKey) ?? '';
    if (legacyRaw.isEmpty) {
      return '';
    }
    if ((prefs.getString(_jvmRawKey) ?? '').isNotEmpty ||
        (prefs.getString(_appRawKey) ?? '').isNotEmpty) {
      return '';
    }
    return legacyRaw;
  }

  Future<void> saveRaw(String value) async {
    await saveStructured(jvmArgsRaw: '', appArgsRaw: value);
  }

  Future<String> loadJvmRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jvmRawKey) ?? '';
  }

  Future<String> loadAppRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final appRaw = prefs.getString(_appRawKey);
    if (appRaw != null) {
      return appRaw;
    }
    return loadRaw();
  }

  Future<void> saveStructured({
    required String jvmArgsRaw,
    required String appArgsRaw,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jvmRawKey, jvmArgsRaw);
    await prefs.setString(_appRawKey, appArgsRaw);
    await prefs.remove(_rawKey);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rawKey);
    await prefs.remove(_jvmRawKey);
    await prefs.remove(_appRawKey);
  }

  Future<List<String>> loadArgs() async {
    return (await loadOptions()).appArgs;
  }

  Future<BackendLaunchOptions> loadOptions() async {
    final jvmRaw = await loadJvmRaw();
    final appRaw = await loadAppRaw();
    return BackendLaunchOptions(
      jvmArgs: _parseLines(jvmRaw),
      appArgs: _parseLines(appRaw),
    );
  }

  List<String> _parseLines(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
  }
}
