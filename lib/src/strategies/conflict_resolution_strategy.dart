import '../models/conflict_resolution.dart';

/// Abstract base class for conflict resolution strategies
abstract class ConflictResolutionStrategyBase {
  /// Resolve a conflict between local and remote data
  Future<ConflictResolutionResult> resolve(Conflict conflict);

  /// Get the strategy name
  String get name;
}

/// Default implementation that throws an error
class DefaultConflictResolutionStrategy extends ConflictResolutionStrategyBase {
  @override
  String get name => 'default';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    return ConflictResolutionResult.failure(
      'No conflict resolution strategy implemented for conflict: ${conflict.key}',
    );
  }
}
