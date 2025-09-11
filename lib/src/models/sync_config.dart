import 'conflict_resolution.dart';

/// Configuration for sync operations
class SyncConfig {
  /// Strategy to use for conflict resolution
  final ConflictResolutionStrategy conflictResolution;
  
  /// Maximum number of retry attempts for failed operations
  final int maxRetries;
  
  /// Delay between retry attempts
  final Duration retryDelay;
  
  /// Whether to sync in background
  final bool backgroundSync;
  
  /// Interval for background sync (if enabled)
  final Duration backgroundSyncInterval;
  
  /// Whether to sync on app start
  final bool syncOnStart;
  
  /// Whether to sync when network becomes available
  final bool syncOnNetworkRestore;
  
  /// Maximum number of items to sync in a single batch
  final int batchSize;
  
  /// Timeout for individual operations
  final Duration operationTimeout;

  const SyncConfig({
    this.conflictResolution = ConflictResolutionStrategy.lastWriteWins,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.backgroundSync = false,
    this.backgroundSyncInterval = const Duration(minutes: 5),
    this.syncOnStart = true,
    this.syncOnNetworkRestore = true,
    this.batchSize = 100,
    this.operationTimeout = const Duration(seconds: 30),
  });

  /// Creates a default configuration
  factory SyncConfig.defaultConfig() {
    return const SyncConfig();
  }

  /// Creates a configuration optimized for offline-first apps
  factory SyncConfig.offlineFirst() {
    return const SyncConfig(
      backgroundSync: true,
      syncOnStart: true,
      syncOnNetworkRestore: true,
      maxRetries: 5,
      retryDelay: Duration(seconds: 1),
    );
  }

  /// Creates a configuration optimized for real-time apps
  factory SyncConfig.realTime() {
    return const SyncConfig(
      backgroundSync: true,
      backgroundSyncInterval: Duration(seconds: 30),
      syncOnStart: true,
      syncOnNetworkRestore: true,
      batchSize: 50,
    );
  }

  @override
  String toString() {
    return 'SyncConfig(conflictResolution: $conflictResolution, '
        'maxRetries: $maxRetries, backgroundSync: $backgroundSync, '
        'batchSize: $batchSize)';
  }
}
