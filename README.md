# Flutter Offline Sync

A Flutter package for seamless offline-first data synchronization between local and remote storage.

## Features

- 🔄 **Two-way sync** (local ↔ remote)
- ⚡ **Conflict resolution strategies** (lastWriteWins, manual, merge, localWins, remoteWins)
- 🔁 **Background sync** with retry on network restore
- 🗄️ **Multiple storage adapters** (Hive, SQLite, SharedPreferences, and more)
- ⚙️ **Configurable sync behavior**
- 🚀 **Easy to use** with simple API

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_offline_sync: ^1.0.1
```

## Quick Start

```dart
import 'package:flutter_offline_sync/flutter_offline_sync.dart';

// Create sync manager
final sync = SyncManager(
  localDb: HiveAdapter(),
  remoteApi: FirestoreAdapter(), // Your custom adapter
);

// Initialize and sync
await sync.initialize();
await sync.sync(); // Automatically merges changes, handles conflicts
```

## Usage

### Basic Setup

```dart
import 'package:flutter_offline_sync/flutter_offline_sync.dart';

class MyApp {
  late SyncManager syncManager;

  Future<void> initialize() async {
    syncManager = SyncManager(
      localDb: HiveAdapter(),
      remoteApi: MyCustomRemoteAdapter(),
      config: SyncConfig.offlineFirst(),
    );
    
    await syncManager.initialize();
  }

  Future<void> syncData() async {
    final result = await syncManager.syncWithRetry();
    if (result.success) {
      print('Sync successful: ${result.localToRemoteCount} local→remote, '
            '${result.remoteToLocalCount} remote→local, '
            '${result.conflictCount} conflicts');
    } else {
      print('Sync failed: ${result.error}');
    }
  }
}
```

### Configuration Options

```dart
final config = SyncConfig(
  conflictResolution: ConflictResolutionStrategy.lastWriteWins,
  maxRetries: 3,
  retryDelay: Duration(seconds: 2),
  backgroundSync: true,
  backgroundSyncInterval: Duration(minutes: 5),
  syncOnStart: true,
  syncOnNetworkRestore: true,
  batchSize: 100,
  operationTimeout: Duration(seconds: 30),
);

// Or use predefined configurations
final offlineFirstConfig = SyncConfig.offlineFirst();
final realTimeConfig = SyncConfig.realTime();
```

### Conflict Resolution Strategies

#### Last Write Wins (Default)
```dart
final config = SyncConfig(
  conflictResolution: ConflictResolutionStrategy.lastWriteWins,
);
```

#### Manual Resolution
```dart
final strategy = ManualResolutionStrategy(
  onConflict: (conflict) async {
    // Show UI to user for manual resolution
    final resolvedData = await showConflictResolutionDialog(conflict);
    return ConflictResolutionResult.success(resolvedData);
  },
);
```

#### Merge Strategy
```dart
final config = SyncConfig(
  conflictResolution: ConflictResolutionStrategy.merge,
);
```

#### Local/Remote Wins
```dart
final config = SyncConfig(
  conflictResolution: ConflictResolutionStrategy.localWins, // or remoteWins
);
```

### Custom Adapters

#### Local Adapter
```dart
class MyLocalAdapter implements LocalAdapter {
  @override
  Future<void> initialize() async {
    // Initialize your local storage
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAll() async {
    // Return all items from local storage
  }

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    // Save item to local storage
  }

  // ... implement other methods
}
```

#### Remote Adapter
```dart
class MyRemoteAdapter implements RemoteAdapter {
  @override
  Future<void> initialize() async {
    // Initialize connection to remote storage
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAll() async {
    // Return all items from remote storage
  }

  @override
  Future<bool> isAvailable() async {
    // Check network connectivity
    return true;
  }

  // ... implement other methods
}
```

### Background Sync

```dart
// Start background sync
syncManager.startBackgroundSync();

// Stop background sync
syncManager.stopBackgroundSync();
```

### Sync Specific Items

```dart
final result = await syncManager.syncItems(['item1', 'item2', 'item3']);
```

## Built-in Adapters

### Hive Adapter
```dart
final localDb = HiveAdapter(boxName: 'my_app_data');
```

### SQLite Adapter
```dart
final localDb = SqliteAdapter(databaseName: 'my_app.db');
```

### SharedPreferences Adapter
```dart
final localDb = SharedPrefsAdapter(prefix: 'my_app_');
```

## Advanced Usage

### Custom Conflict Resolution

```dart
class CustomConflictStrategy extends ConflictResolutionStrategy {
  @override
  String get name => 'custom';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    // Your custom logic here
    final resolvedData = {
      ...conflict.localData,
      'merged_at': DateTime.now().toIso8601String(),
    };
    
    return ConflictResolutionResult.success(resolvedData);
  }
}
```

### Error Handling

```dart
try {
  final result = await syncManager.sync();
  if (!result.success) {
    // Handle sync failure
    print('Sync failed: ${result.error}');
  }
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

## Example App

Check out the `example/` directory for a complete Flutter app demonstrating the package usage.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Issues

If you find any issues or have feature requests, please file them at [GitHub Issues](https://github.com/Shubham5250/offline_sync/issues).
