import 'local_adapter.dart';

/// Hive adapter implementation for local storage
/// 
/// This adapter provides a working implementation for demonstration purposes.
/// For production use, add the hive package as a dependency and implement
/// the actual Hive database operations.
class HiveAdapter implements LocalAdapter {
  final String boxName;
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};

  HiveAdapter({this.boxName = 'offline_sync'});

  @override
  Future<void> initialize() async {
    // Initialize Hive database
    // await Hive.initFlutter();
    // _box = await Hive.openBox(boxName);
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
    // Close Hive box
    // await _box?.close();
  }
}
