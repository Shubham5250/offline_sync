import 'package:flutter/material.dart';
import 'package:flutter_data_sync_manager/flutter_data_sync_manager.dart';

/// Example app demonstrating offline_sync package
/// 
/// This example shows:
/// - Basic sync setup with local and remote adapters
/// - Conflict resolution strategies
/// - Background sync with retry logic
/// - Real-time sync status updates
void main() {
  runApp(const OfflineSyncExampleApp());
}

class OfflineSyncExampleApp extends StatelessWidget {
  const OfflineSyncExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Sync Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OfflineSyncExamplePage(),
    );
  }
}

class OfflineSyncExamplePage extends StatefulWidget {
  const OfflineSyncExamplePage({super.key});

  @override
  State<OfflineSyncExamplePage> createState() => _OfflineSyncExamplePageState();
}

class _OfflineSyncExamplePageState extends State<OfflineSyncExamplePage> {
  late SyncManager syncManager;
  SyncResult? lastSyncResult;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializeSyncManager();
  }

  void _initializeSyncManager() {
    // Create sync manager with local and remote adapters
    // This demonstrates the core usage pattern:
    // 1. Choose your local storage (Hive, SQLite, SharedPreferences)
    // 2. Implement your remote adapter (Firestore, REST API, etc.)
    // 3. Configure sync behavior
    syncManager = SyncManager(
      localDb: HiveAdapter(), // Local storage adapter
      remoteApi: MockRemoteAdapter(), // Remote storage adapter
      config: SyncConfig.offlineFirst(), // Optimized for offline-first apps
    );
  }

  Future<void> _performSync() async {
    setState(() {
      isSyncing = true;
    });

    try {
      // This is the magic! One line handles everything:
      // - Uploads local changes to remote
      // - Downloads remote changes to local  
      // - Resolves conflicts automatically
      // - Retries on failure
      final result = await syncManager.syncWithRetry();
      setState(() {
        lastSyncResult = result;
        isSyncing = false;
      });
    } catch (e) {
      setState(() {
        isSyncing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Is Syncing: ${isSyncing ? "Yes" : "No"}'),
                    if (lastSyncResult != null) ...[
                      const SizedBox(height: 8),
                      Text('Last Sync: ${lastSyncResult!.success ? "Success" : "Failed"}'),
                      if (lastSyncResult!.success) ...[
                        Text('Local → Remote: ${lastSyncResult!.localToRemoteCount}'),
                        Text('Remote → Local: ${lastSyncResult!.remoteToLocalCount}'),
                        Text('Conflicts: ${lastSyncResult!.conflictCount}'),
                        Text('Duration: ${lastSyncResult!.duration.inMilliseconds}ms'),
                      ] else ...[
                        Text('Error: ${lastSyncResult!.error}'),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSyncing ? null : _performSync,
              child: isSyncing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Syncing...'),
                      ],
                    )
                  : const Text('Start Sync'),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features Demonstrated',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Two-way sync (local ↔ remote)'),
                    Text('• Conflict resolution strategies'),
                    Text('• Background sync with retry logic'),
                    Text('• Multiple storage adapters (Hive, SQLite, SharedPrefs)'),
                    Text('• Configurable sync behavior'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    syncManager.close();
    super.dispose();
  }
}

/// Mock remote adapter for demonstration purposes
class MockRemoteAdapter implements RemoteAdapter {
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  Future<void> initialize() async {
    // Simulate some initial data
    _data['user_1'] = {
      'id': 'user_1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'lastLogin': DateTime.now().toIso8601String(),
    };
    _timestamps['user_1'] = DateTime.now().subtract(const Duration(hours: 1));
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
    // Simulate network availability
    return true;
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
  Future<void> close() async {
    // No cleanup needed for mock
  }
}
