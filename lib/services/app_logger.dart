import 'package:shared_preferences/shared_preferences.dart';

class AppLogger {
  static const String _storageKey = 'app_debug_logs';
  static const int _maxEntries = 300;
  static final List<String> _entries = <String>[];
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? const <String>[];
    _entries
      ..clear()
      ..addAll(saved);
    _isInitialized = true;
  }

  static Future<void> log(
    String source,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await init();
    final now = DateTime.now().toIso8601String();
    final base = '[$now][$source] $message';
    final err = error == null ? '' : '\nERROR: $error';
    final stack = stackTrace == null ? '' : '\nSTACK:\n$stackTrace';
    _entries.add('$base$err$stack');

    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _entries);
  }

  static Future<List<String>> readAll() async {
    await init();
    return List<String>.from(_entries);
  }

  static Future<String> asText() async {
    await init();
    if (_entries.isEmpty) {
      return '[${DateTime.now().toIso8601String()}] No logs captured';
    }
    return _entries.join('\n\n');
  }

  static Future<void> clear() async {
    await init();
    _entries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
