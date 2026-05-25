import 'package:shared_preferences/shared_preferences.dart';

class BackendLaunchArgs {
  static const String _rawKey = 'backend_launch_args_raw';

  Future<String> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rawKey) ?? '';
  }

  Future<void> saveRaw(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rawKey, value);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rawKey);
  }

  Future<List<String>> loadArgs() async {
    final raw = await loadRaw();
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}
