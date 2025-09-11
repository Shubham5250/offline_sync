import '../models/conflict_resolution.dart';
import 'conflict_resolution_strategy.dart';

/// Strategy that requires manual resolution of conflicts
class ManualResolutionStrategy extends ConflictResolutionStrategyBase {
  /// Callback function to handle manual conflict resolution
  final Future<ConflictResolutionResult> Function(Conflict conflict)? onConflict;

  ManualResolutionStrategy({this.onConflict});

  @override
  String get name => 'manual';

  @override
  Future<ConflictResolutionResult> resolve(Conflict conflict) async {
    if (onConflict != null) {
      return await onConflict!(conflict);
    }
    
    // If no callback is provided, return the local data as default
    return ConflictResolutionResult.success(
      Map<String, dynamic>.from(conflict.localData),
    );
  }
}
