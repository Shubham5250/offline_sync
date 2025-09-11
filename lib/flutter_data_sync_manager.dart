library flutter_data_sync_manager;

// Core classes
export 'src/sync_manager.dart';
export 'src/models/sync_result.dart';
export 'src/models/sync_config.dart';
export 'src/models/conflict_resolution.dart';
export 'src/network_status_monitor.dart';

// Adapter interfaces
export 'src/adapters/local_adapter.dart';
export 'src/adapters/remote_adapter.dart';

// Conflict resolution strategies
export 'src/strategies/conflict_resolution_strategy.dart';
export 'src/strategies/last_write_wins_strategy.dart';
export 'src/strategies/manual_resolution_strategy.dart';
export 'src/strategies/merge_strategy.dart';

// Built-in adapters (optional dependencies)
export 'src/adapters/hive_adapter.dart' show HiveAdapter;
export 'src/adapters/sqlite_adapter.dart' show SqliteAdapter;
export 'src/adapters/shared_prefs_adapter.dart' show SharedPrefsAdapter;
