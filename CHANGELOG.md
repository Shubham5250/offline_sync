# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-XX

### Added
- Initial release of Offline Sync package
- Core `SyncManager` class for managing sync operations
- Support for two-way sync (local ↔ remote)
- Multiple conflict resolution strategies:
  - Last Write Wins
  - Manual Resolution
  - Merge Strategy
  - Local Wins
  - Remote Wins
- Background sync with configurable intervals
- Retry logic with exponential backoff
- Built-in adapters for common storage solutions:
  - Hive Adapter
  - SQLite Adapter
  - SharedPreferences Adapter
- Comprehensive configuration options
- Extensive test coverage
- Example Flutter app demonstrating usage
- Complete documentation and README

### Features
- **SyncManager**: Main class for managing offline sync operations
- **Conflict Resolution**: Multiple strategies for handling data conflicts
- **Background Sync**: Automatic syncing in the background
- **Retry Logic**: Automatic retry on network failures
- **Configurable**: Highly configurable sync behavior
- **Extensible**: Easy to create custom adapters
- **Type Safe**: Full type safety with Dart's type system

### API
- `SyncManager` - Main sync manager class
- `SyncConfig` - Configuration for sync operations
- `SyncResult` - Result of sync operations
- `Conflict` - Represents a data conflict
- `ConflictResolutionResult` - Result of conflict resolution
- `LocalAdapter` - Interface for local storage
- `RemoteAdapter` - Interface for remote storage
- `ConflictResolutionStrategy` - Interface for conflict resolution

### Dependencies
- Flutter SDK >=3.10.0
- Dart SDK >=3.0.0
- No external dependencies (adapters are optional)
