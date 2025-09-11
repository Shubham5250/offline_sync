# Offline Sync Example

This example demonstrates how to use the `offline_sync` package in a Flutter app.

## What this example shows

- **Basic setup**: How to create a `SyncManager` with local and remote adapters
- **Sync operations**: Performing two-way sync between local and remote storage
- **Conflict resolution**: How conflicts are automatically resolved
- **Background sync**: Automatic syncing with retry logic
- **Real-time status**: Live updates of sync status and results

## Key features demonstrated

1. **Offline-first approach**: App works without internet connection
2. **Automatic conflict resolution**: Uses configurable strategies
3. **Background synchronization**: Syncs data in the background
4. **Retry logic**: Automatically retries failed operations
5. **Status monitoring**: Real-time sync status updates

## Running the example

```bash
cd example
flutter pub get
flutter run
```

## Code highlights

### Basic setup
```dart
final syncManager = SyncManager(
  localDb: HiveAdapter(), // Local storage
  remoteApi: MockRemoteAdapter(), // Remote storage
  config: SyncConfig.offlineFirst(), // Configuration
);
```

### Performing sync
```dart
// One line handles everything:
// - Uploads local changes to remote
// - Downloads remote changes to local
// - Resolves conflicts automatically
// - Retries on failure
final result = await syncManager.syncWithRetry();
```

### Handling results
```dart
if (result.success) {
  print('✅ Sync successful!');
  print('📤 Uploaded: ${result.localToRemoteCount} items');
  print('📥 Downloaded: ${result.remoteToLocalCount} items');
  print('⚠️ Conflicts: ${result.conflictCount}');
} else {
  print('❌ Sync failed: ${result.error}');
}
```

## Files

- `main.dart` - Main example app demonstrating basic sync functionality
- `todo_app_example.dart` - Complete todo app example with offline sync
- `pubspec.yaml` - Example app dependencies

## Learn more

- [Package documentation](../README.md)
- [API reference](https://pub.dev/documentation/offline_sync/latest/)
- [GitHub repository](https://github.com/Shubham5250/offline_sync)
