import 'local_adapter.dart';

/// SQLite adapter implementation for local storage
///
/// This adapter provides a working implementation for demonstration purposes.
/// For production use, add the sqflite package as a dependency and implement
/// the actual SQLite database operations.
class SqliteAdapter implements LocalAdapter {
  final String databaseName;
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};

  SqliteAdapter({this.databaseName = 'offline_sync.db'});

  @override
  Future<void> initialize() async {
    // Initialize SQLite database
    // _database = await openDatabase(
    //   join(await getDatabasesPath(), databaseName),
    //   version: 1,
    //   onCreate: (db, version) {
    //     return db.execute(
    //       'CREATE TABLE sync_data(key TEXT PRIMARY KEY, data TEXT, last_modified INTEGER)',
    //     );
    //   },
    // );
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
    // Close SQLite database
    // await _database?.close();
  }
}
