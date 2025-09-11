/// Enumeration of available conflict resolution strategies
enum ConflictResolutionStrategy {
  /// Last write wins - the most recent timestamp wins
  lastWriteWins,

  /// Manual resolution - conflicts are reported for manual handling
  manual,

  /// Merge strategy - attempts to merge non-conflicting fields
  merge,

  /// Local wins - local changes always take precedence
  localWins,

  /// Remote wins - remote changes always take precedence
  remoteWins,
}

/// Represents a conflict between local and remote data
class Conflict {
  /// The key/ID of the conflicted item
  final String key;

  /// Local version of the data
  final Map<String, dynamic> localData;

  /// Remote version of the data
  final Map<String, dynamic> remoteData;

  /// Timestamp of local change
  final DateTime localTimestamp;

  /// Timestamp of remote change
  final DateTime remoteTimestamp;

  /// Fields that are in conflict
  final List<String> conflictingFields;

  const Conflict({
    required this.key,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.conflictingFields,
  });

  @override
  String toString() {
    return 'Conflict(key: $key, conflictingFields: $conflictingFields, '
        'localTimestamp: $localTimestamp, remoteTimestamp: $remoteTimestamp)';
  }
}

/// Result of conflict resolution
class ConflictResolutionResult {
  /// The resolved data
  final Map<String, dynamic> resolvedData;

  /// Whether the resolution was successful
  final bool success;

  /// Error message if resolution failed
  final String? error;

  const ConflictResolutionResult({
    required this.resolvedData,
    required this.success,
    this.error,
  });

  /// Creates a successful resolution result
  factory ConflictResolutionResult.success(Map<String, dynamic> data) {
    return ConflictResolutionResult(
      resolvedData: data,
      success: true,
    );
  }

  /// Creates a failed resolution result
  factory ConflictResolutionResult.failure(String error) {
    return ConflictResolutionResult(
      resolvedData: {},
      success: false,
      error: error,
    );
  }
}
