import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sync/offline_sync.dart';

void main() {
  group('SyncManager Tests', () {
    late SyncManager syncManager;
    late MockLocalAdapter localAdapter;
    late MockRemoteAdapter remoteAdapter;

    setUp(() {
      localAdapter = MockLocalAdapter();
      remoteAdapter = MockRemoteAdapter();
      syncManager = SyncManager(
        localDb: localAdapter,
        remoteApi: remoteAdapter,
        config: SyncConfig.defaultConfig(),
      );
    });

    tearDown(() {
      syncManager.close();
    });

    test('should initialize successfully', () async {
      await syncManager.initialize();
      expect(syncManager.isSyncing, false);
    });

    test('should perform sync successfully', () async {
      await syncManager.initialize();
      
      // Add some test data
      await localAdapter.save('test_key', {'value': 'local_data'});
      await remoteAdapter.save('test_key', {'value': 'remote_data'});
      
      final result = await syncManager.sync();
      
      expect(result.success, true);
      expect(result.localToRemoteCount, greaterThanOrEqualTo(0));
      expect(result.remoteToLocalCount, greaterThanOrEqualTo(0));
    });

    test('should handle sync failure when remote is unavailable', () async {
      await syncManager.initialize();
      remoteAdapter.setAvailable(false);
      
      final result = await syncManager.sync();
      
      expect(result.success, false);
      expect(result.error, contains('not available'));
    });

    test('should sync specific items', () async {
      await syncManager.initialize();
      
      await localAdapter.save('item1', {'value': 'local1'});
      await localAdapter.save('item2', {'value': 'local2'});
      
      final result = await syncManager.syncItems(['item1', 'item2']);
      
      expect(result.success, true);
    });
  });

  group('Conflict Resolution Tests', () {
    test('LastWriteWinsStrategy should choose newer timestamp', () async {
      final strategy = LastWriteWinsStrategy();
      final conflict = Conflict(
        key: 'test',
        localData: {'value': 'local'},
        remoteData: {'value': 'remote'},
        localTimestamp: DateTime.now(),
        remoteTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        conflictingFields: ['value'],
      );
      
      final result = await strategy.resolve(conflict);
      
      expect(result.success, true);
      expect(result.resolvedData['value'], 'local');
    });

    test('LocalWinsStrategy should always choose local data', () async {
      final strategy = LocalWinsStrategy();
      final conflict = Conflict(
        key: 'test',
        localData: {'value': 'local'},
        remoteData: {'value': 'remote'},
        localTimestamp: DateTime.now(),
        remoteTimestamp: DateTime.now(),
        conflictingFields: ['value'],
      );
      
      final result = await strategy.resolve(conflict);
      
      expect(result.success, true);
      expect(result.resolvedData['value'], 'local');
    });

    test('RemoteWinsStrategy should always choose remote data', () async {
      final strategy = RemoteWinsStrategy();
      final conflict = Conflict(
        key: 'test',
        localData: {'value': 'local'},
        remoteData: {'value': 'remote'},
        localTimestamp: DateTime.now(),
        remoteTimestamp: DateTime.now(),
        conflictingFields: ['value'],
      );
      
      final result = await strategy.resolve(conflict);
      
      expect(result.success, true);
      expect(result.resolvedData['value'], 'remote');
    });
  });

  group('SyncConfig Tests', () {
    test('should create default config', () {
      final config = SyncConfig.defaultConfig();
      expect(config.conflictResolution, ConflictResolutionStrategy.lastWriteWins);
      expect(config.maxRetries, 3);
      expect(config.backgroundSync, false);
    });

    test('should create offline-first config', () {
      final config = SyncConfig.offlineFirst();
      expect(config.backgroundSync, true);
      expect(config.syncOnStart, true);
      expect(config.syncOnNetworkRestore, true);
      expect(config.maxRetries, 5);
    });

    test('should create real-time config', () {
      final config = SyncConfig.realTime();
      expect(config.backgroundSync, true);
      expect(config.backgroundSyncInterval, const Duration(seconds: 30));
      expect(config.batchSize, 50);
    });
  });
}

/// Mock local adapter for testing
class MockLocalAdapter implements LocalAdapter {
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  Future<void> initialize() async {}

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
    _data[key] = Map<String, dynamic>.from(data);
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
  Future<void> close() async {}
}

/// Mock remote adapter for testing
class MockRemoteAdapter implements RemoteAdapter {
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};
  bool _available = true;

  void setAvailable(bool available) {
    _available = available;
  }

  @override
  Future<void> initialize() async {}

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
    _data[key] = Map<String, dynamic>.from(data);
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
  Future<bool> isAvailable() async {
    return _available;
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getModifiedSince(DateTime timestamp) async {
    final result = <String, Map<String, dynamic>>{};
    for (final entry in _timestamps.entries) {
      if (entry.value.isAfter(timestamp)) {
        result[entry.key] = _data[entry.key]!;
      }
    }
    return result;
  }

  @override
  Future<void> close() async {}
}
