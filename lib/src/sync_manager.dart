import 'dart:async';

import 'adapters/local_adapter.dart';
import 'adapters/remote_adapter.dart';
import 'models/sync_config.dart';
import 'models/sync_result.dart';
import 'models/conflict_resolution.dart';
import 'strategies/conflict_resolution_strategy.dart';
import 'strategies/last_write_wins_strategy.dart';
import 'strategies/manual_resolution_strategy.dart';
import 'strategies/merge_strategy.dart';
import 'network_status_monitor.dart';

/// Main class for managing offline sync operations
class SyncManager {
  final LocalAdapter localDb;
  final RemoteAdapter remoteApi;
  final SyncConfig config;
  
  ConflictResolutionStrategyBase? _conflictStrategy;
  Timer? _backgroundSyncTimer;
  NetworkStatusMonitor? _networkMonitor;
  bool _isInitialized = false;
  bool _isSyncing = false;

  SyncManager({
    required this.localDb,
    required this.remoteApi,
    SyncConfig? config,
  }) : config = config ?? SyncConfig.defaultConfig();

  /// Initialize the sync manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await localDb.initialize();
    await remoteApi.initialize();
    
    _setupConflictResolutionStrategy();
    _setupNetworkMonitoring();
    
    if (config.backgroundSync) {
      _startBackgroundSync();
    }
    
    _isInitialized = true;
  }

  /// Perform a full sync operation
  Future<SyncResult> sync() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isSyncing) {
      return SyncResult.failure(
        error: 'Sync already in progress',
        duration: Duration.zero,
      );
    }
    
    _isSyncing = true;
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check if remote is available
      if (!await remoteApi.isAvailable()) {
        return SyncResult.failure(
          error: 'Remote storage not available',
          duration: stopwatch.elapsed,
        );
      }
      
      int localToRemoteCount = 0;
      int remoteToLocalCount = 0;
      int conflictCount = 0;
      
      // Get all data from both sources
      final localData = await localDb.getAll();
      final remoteData = await remoteApi.getAll();
      
      // Find conflicts and sync changes
      final conflicts = _findConflicts(localData, remoteData);
      conflictCount = conflicts.length;
      
      // Resolve conflicts
      for (final conflict in conflicts) {
        final resolution = await _conflictStrategy!.resolve(conflict);
        if (resolution.success) {
          // Save resolved data to both local and remote
          await localDb.save(conflict.key, resolution.resolvedData);
          await remoteApi.save(conflict.key, resolution.resolvedData);
        }
      }
      
      // Sync local changes to remote
      for (final entry in localData.entries) {
        final key = entry.key;
        final localItem = entry.value;
        final remoteItem = remoteData[key];
        
        if (remoteItem == null || _isLocalNewer(key, localItem, remoteItem)) {
          await remoteApi.save(key, localItem);
          localToRemoteCount++;
        }
      }
      
      // Sync remote changes to local
      for (final entry in remoteData.entries) {
        final key = entry.key;
        final remoteItem = entry.value;
        final localItem = localData[key];
        
        if (localItem == null || _isRemoteNewer(key, localItem, remoteItem)) {
          await localDb.save(key, remoteItem);
          remoteToLocalCount++;
        }
      }
      
      stopwatch.stop();
      return SyncResult.success(
        localToRemoteCount: localToRemoteCount,
        remoteToLocalCount: remoteToLocalCount,
        conflictCount: conflictCount,
        duration: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      return SyncResult.failure(
        error: 'Sync failed: $e',
        duration: stopwatch.elapsed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform sync with retry logic
  Future<SyncResult> syncWithRetry() async {
    int attempts = 0;
    SyncResult? lastResult;
    
    while (attempts < config.maxRetries) {
      lastResult = await sync();
      
      if (lastResult.success) {
        return lastResult;
      }
      
      attempts++;
      if (attempts < config.maxRetries) {
        await Future.delayed(config.retryDelay);
      }
    }
    
    return lastResult!;
  }

  /// Force sync specific items
  Future<SyncResult> syncItems(List<String> keys) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final stopwatch = Stopwatch()..start();
    
    try {
      int localToRemoteCount = 0;
      int remoteToLocalCount = 0;
      
      for (final key in keys) {
        final localItem = await localDb.get(key);
        final remoteItem = await remoteApi.get(key);
        
        if (localItem != null && remoteItem != null) {
          // Check for conflicts
          if (_hasConflict(key, localItem, remoteItem)) {
            final conflict = Conflict(
              key: key,
              localData: localItem,
              remoteData: remoteItem,
              localTimestamp: await localDb.getLastModified(key) ?? DateTime.now(),
              remoteTimestamp: await remoteApi.getLastModified(key) ?? DateTime.now(),
              conflictingFields: _getConflictingFields(localItem, remoteItem),
            );
            
            final resolution = await _conflictStrategy!.resolve(conflict);
            if (resolution.success) {
              await localDb.save(key, resolution.resolvedData);
              await remoteApi.save(key, resolution.resolvedData);
            }
          } else if (_isLocalNewer(key, localItem, remoteItem)) {
            await remoteApi.save(key, localItem);
            localToRemoteCount++;
          } else if (_isRemoteNewer(key, localItem, remoteItem)) {
            await localDb.save(key, remoteItem);
            remoteToLocalCount++;
          }
        } else if (localItem != null) {
          await remoteApi.save(key, localItem);
          localToRemoteCount++;
        } else if (remoteItem != null) {
          await localDb.save(key, remoteItem);
          remoteToLocalCount++;
        }
      }
      
      stopwatch.stop();
      return SyncResult.success(
        localToRemoteCount: localToRemoteCount,
        remoteToLocalCount: remoteToLocalCount,
        conflictCount: 0,
        duration: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      return SyncResult.failure(
        error: 'Item sync failed: $e',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Start background sync
  void startBackgroundSync() {
    if (!config.backgroundSync) return;
    _startBackgroundSync();
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
  }

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Check if device has network connectivity
  bool get isNetworkAvailable => _networkMonitor?.isConnected ?? false;

  /// Get the network status monitor for advanced usage
  NetworkStatusMonitor? get networkMonitor => _networkMonitor;

  /// Close the sync manager and cleanup resources
  Future<void> close() async {
    stopBackgroundSync();
    _networkMonitor?.dispose();
    await localDb.close();
    await remoteApi.close();
    _isInitialized = false;
  }

  void _setupConflictResolutionStrategy() {
    switch (config.conflictResolution) {
      case ConflictResolutionStrategy.lastWriteWins:
        _conflictStrategy = LastWriteWinsStrategy();
        break;
      case ConflictResolutionStrategy.manual:
        _conflictStrategy = ManualResolutionStrategy();
        break;
      case ConflictResolutionStrategy.merge:
        _conflictStrategy = MergeStrategy();
        break;
      case ConflictResolutionStrategy.localWins:
        _conflictStrategy = LocalWinsStrategy();
        break;
      case ConflictResolutionStrategy.remoteWins:
        _conflictStrategy = RemoteWinsStrategy();
        break;
    }
  }

  void _setupNetworkMonitoring() {
    if (!config.syncOnNetworkRestore) return;
    
    try {
      _networkMonitor = NetworkStatusMonitor();
      _networkMonitor!.initialize();
      
      // Auto-sync when network becomes available
      _networkMonitor!.onConnected(() {
        if (!_isSyncing) {
          syncWithRetry();
        }
      });
    } catch (e) {
      // Network monitoring not available (e.g., in tests)
      // Continue without network monitoring
    }
  }

  void _startBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = Timer.periodic(
      config.backgroundSyncInterval,
      (_) => syncWithRetry(),
    );
  }

  List<Conflict> _findConflicts(
    Map<String, Map<String, dynamic>> localData,
    Map<String, Map<String, dynamic>> remoteData,
  ) {
    final conflicts = <Conflict>[];
    
    for (final key in localData.keys) {
      if (remoteData.containsKey(key)) {
        final localItem = localData[key]!;
        final remoteItem = remoteData[key]!;
        
        if (_hasConflict(key, localItem, remoteItem)) {
          final localTimestamp = localItem['_lastModified'] as DateTime? ?? DateTime.now();
          final remoteTimestamp = remoteItem['_lastModified'] as DateTime? ?? DateTime.now();
          
          conflicts.add(Conflict(
            key: key,
            localData: localItem,
            remoteData: remoteItem,
            localTimestamp: localTimestamp,
            remoteTimestamp: remoteTimestamp,
            conflictingFields: _getConflictingFields(localItem, remoteItem),
          ));
        }
      }
    }
    
    return conflicts;
  }

  bool _hasConflict(String key, Map<String, dynamic> local, Map<String, dynamic> remote) {
    return _getConflictingFields(local, remote).isNotEmpty;
  }

  List<String> _getConflictingFields(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final conflictingFields = <String>[];
    
    for (final key in local.keys) {
      if (remote.containsKey(key) && local[key] != remote[key]) {
        conflictingFields.add(key);
      }
    }
    
    return conflictingFields;
  }

  bool _isLocalNewer(String key, Map<String, dynamic> local, Map<String, dynamic> remote) {
    // Check timestamps first if available
    final localTimestamp = local['_lastModified'] as DateTime?;
    final remoteTimestamp = remote['_lastModified'] as DateTime?;
    
    if (localTimestamp != null && remoteTimestamp != null) {
      return localTimestamp.isAfter(remoteTimestamp);
    }
    
    // If no timestamps, use field count as comparison
    return local.length >= remote.length;
  }

  bool _isRemoteNewer(String key, Map<String, dynamic> local, Map<String, dynamic> remote) {
    // Check timestamps first if available
    final localTimestamp = local['_lastModified'] as DateTime?;
    final remoteTimestamp = remote['_lastModified'] as DateTime?;
    
    if (localTimestamp != null && remoteTimestamp != null) {
      return remoteTimestamp.isAfter(localTimestamp);
    }
    
    // If no timestamps, use field count as comparison
    return remote.length > local.length;
  }
}

/// Strategy that always chooses local data
class LocalWinsStrategy extends ConflictResolutionStrategyBase {
  @override
  String get name => 'localWins';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    return ConflictResolutionResult.success(
      Map<String, dynamic>.from(conflict.localData),
    );
  }
}

/// Strategy that always chooses remote data
class RemoteWinsStrategy extends ConflictResolutionStrategyBase {
  @override
  String get name => 'remoteWins';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    return ConflictResolutionResult.success(
      Map<String, dynamic>.from(conflict.remoteData),
    );
  }
}
