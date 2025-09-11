import 'local_adapter.dart';

/// SharedPreferences adapter implementation for local storage
/// Note: This is a placeholder implementation. In a real package,
/// you would need to add shared_preferences as a dependency and implement properly.
class SharedPrefsAdapter implements LocalAdapter {
  final String prefix;
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};

  SharedPrefsAdapter({this.prefix = 'offline_sync'});

  @override
  Future<void> initialize() async {
    // In a real implementation, this would initialize SharedPreferences
    // _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAll() async {
    return Map<String, Map<String, dynamic>>.from(_data);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    return _data[key];
  }

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    final dataWithTimestamp = Map<String, dynamic>.from(data);
    dataWithTimestamp['_lastModified'] = DateTime.now();
    _data[key] = dataWithTimestamp;
    _timestamps[key] = DateTime.now();
  }

  @override
  Future<void> saveAll(Map<String, Map<String, dynamic>> items) async {
    for (final entry in items.entries) {
      await save(entry.key, entry.value);
    }
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
    _timestamps.remove(key);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  @override
  Future<bool> exists(String key) async {
    return _data.containsKey(key);
  }

  @override
  Future<DateTime?> getLastModified(String key) async {
    return _timestamps[key];
  }

  @override
  Future<void> updateLastModified(String key, DateTime timestamp) async {
    _timestamps[key] = timestamp;
  }

  @override
  Future<void> clear() async {
    _data.clear();
    _timestamps.clear();
  }

  @override
  Future<int> count() async {
    return _data.length;
  }

  @override
  Future<void> close() async {
    // SharedPreferences doesn't need explicit closing
  }
}
