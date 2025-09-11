import '../models/conflict_resolution.dart';
import 'conflict_resolution_strategy.dart';

/// Strategy that resolves conflicts by choosing the most recent timestamp
class LastWriteWinsStrategy extends ConflictResolutionStrategyBase {
  @override
  String get name => 'lastWriteWins';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    try {
      // Choose the data with the most recent timestamp
      final Map<String, dynamic> resolvedData;
      
      if (conflict.localTimestamp.isAfter(conflict.remoteTimestamp)) {
        resolvedData = Map<String, dynamic>.from(conflict.localData);
      } else {
        resolvedData = Map<String, dynamic>.from(conflict.remoteData);
      }
      
      return ConflictResolutionResult.success(resolvedData);
    } catch (e) {
      return ConflictResolutionResult.failure(
        'Failed to resolve conflict using last write wins strategy: $e',
      );
    }
  }
}
