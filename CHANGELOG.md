# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.3] - 2025-09-12

### Documentation
- Cleaned up CHANGELOG entries

## [1.1.2] - 2025-09-12

### Documentation
- Improved documentation structure and organization

## [1.1.1] - 2025-09-12

### Fixed
- Updated dependencies to latest versions for better pub.dev score
- Fixed Dart formatting issues across all files
- Improved code quality and static analysis compliance

## [1.1.0] - 2025-09-12

### Added
- Network status monitoring with automatic sync triggering
- Connectivity detection using connectivity_plus package
- Auto-sync when network becomes available
- Network status callbacks for custom handling
- Public API to check network availability
- Enhanced user experience with seamless offline-to-online transitions

### Fixed
- Improved timestamp comparison logic in sync operations
- Enhanced conflict resolution with proper timestamp handling
- Fixed GitHub repository URLs in documentation

## [1.0.1] - 2025-01-27

### Fixed
- Improved timestamp comparison logic in sync operations
- Enhanced conflict resolution with proper timestamp handling
- Fixed GitHub repository URLs in documentation

## [1.0.0] - 2025-01-27

### Added
- Initial release of Flutter Data Sync Manager package
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
- connectivity_plus ^7.0.0
- collection ^1.19.1
- meta ^1.16.0