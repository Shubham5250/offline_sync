/// Represents the result of a sync operation
class SyncResult {
  /// Whether the sync was successful
  final bool success;
  
  /// Number of items synced from local to remote
  final int localToRemoteCount;
  
  /// Number of items synced from remote to local
  final int remoteToLocalCount;
  
  /// Number of conflicts encountered
  final int conflictCount;
  
  /// Error message if sync failed
  final String? error;
  
  /// Duration of the sync operation
  final Duration duration;
  
  /// Timestamp when sync completed
  final DateTime timestamp;

  const SyncResult({
    required this.success,
    required this.localToRemoteCount,
    required this.remoteToLocalCount,
    required this.conflictCount,
    required this.duration,
    required this.timestamp,
    this.error,
  });

  /// Creates a successful sync result
  factory SyncResult.success({
    required int localToRemoteCount,
    required int remoteToLocalCount,
    required int conflictCount,
    required Duration duration,
  }) {
    return SyncResult(
      success: true,
      localToRemoteCount: localToRemoteCount,
      remoteToLocalCount: remoteToLocalCount,
      conflictCount: conflictCount,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a failed sync result
  factory SyncResult.failure({
    required String error,
    required Duration duration,
  }) {
    return SyncResult(
      success: false,
      localToRemoteCount: 0,
      remoteToLocalCount: 0,
      conflictCount: 0,
      duration: duration,
      timestamp: DateTime.now(),
      error: error,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'SyncResult(success: true, localToRemote: $localToRemoteCount, '
          'remoteToLocal: $remoteToLocalCount, conflicts: $conflictCount, '
          'duration: ${duration.inMilliseconds}ms)';
    } else {
      return 'SyncResult(success: false, error: $error, '
          'duration: ${duration.inMilliseconds}ms)';
    }
  }
}
