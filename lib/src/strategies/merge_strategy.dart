import '../models/conflict_resolution.dart';
import 'conflict_resolution_strategy.dart';

/// Strategy that attempts to merge non-conflicting fields
class MergeStrategy extends ConflictResolutionStrategyBase {
  @override
  String get name => 'merge';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    try {
      final Map<String, dynamic> mergedData = {};

      // Start with local data as base
      mergedData.addAll(conflict.localData);

      // Add non-conflicting fields from remote data
      for (final entry in conflict.remoteData.entries) {
        final key = entry.key;
        final remoteValue = entry.value;

        // If the field is not in conflict, use remote value
        if (!conflict.conflictingFields.contains(key)) {
          mergedData[key] = remoteValue;
        }
        // For conflicting fields, prefer local value (could be configurable)
        else {
          mergedData[key] = conflict.localData[key];
        }
      }

      return ConflictResolutionResult.success(mergedData);
    } catch (e) {
      return ConflictResolutionResult.failure(
        'Failed to resolve conflict using merge strategy: $e',
      );
    }
  }
}
