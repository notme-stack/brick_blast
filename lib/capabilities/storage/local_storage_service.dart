import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String hasCompletedLoginKey = 'has_completed_login';

  static final Map<String, Object?> _memory = {};
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    for (final key in _prefs!.getKeys()) {
      _memory[key] = _prefs!.get(key);
    }
  }

  T? read<T>(String key) {
    final value = _memory[key];
    if (value is T) {
      return value;
    }
    if (value == null) {
      return null;
    }
    return null;
  }

  Future<void> write(String key, Object? value) async {
    _memory[key] = value;
    if (_prefs == null) {
      return;
    }

    if (value == null) {
      await _prefs!.remove(key);
      return;
    }
    if (value is int) {
      await _prefs!.setInt(key, value);
      return;
    }
    if (value is double) {
      await _prefs!.setDouble(key, value);
      return;
    }
    if (value is bool) {
      await _prefs!.setBool(key, value);
      return;
    }
    if (value is String) {
      await _prefs!.setString(key, value);
      return;
    }
    if (value is List<String>) {
      await _prefs!.setStringList(key, value);
      return;
    }
    throw UnsupportedError(
      'Unsupported storage value type: ${value.runtimeType}',
    );
  }

  static void clear() {
    _memory.clear();
    final prefs = _prefs;
    if (prefs != null) {
      // Best-effort test cleanup in environments where storage is initialized.
      prefs.clear();
    }
  }
}
