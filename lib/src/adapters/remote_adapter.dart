/// Interface for remote storage adapters
abstract class RemoteAdapter {
  /// Initialize the remote storage connection
  Future<void> initialize();

  /// Get all items from remote storage
  Future<Map<String, Map<String, dynamic>>> getAll();

  /// Get a specific item by key
  Future<Map<String, dynamic>?> get(String key);

  /// Save an item to remote storage
  Future<void> save(String key, Map<String, dynamic> data);

  /// Save multiple items to remote storage
  Future<void> saveAll(Map<String, Map<String, dynamic>> items);

  /// Delete an item from remote storage
  Future<void> delete(String key);

  /// Delete multiple items from remote storage
  Future<void> deleteAll(List<String> keys);

  /// Check if an item exists in remote storage
  Future<bool> exists(String key);

  /// Get the timestamp of when an item was last modified
  Future<DateTime?> getLastModified(String key);

  /// Check if the remote storage is available (network connectivity)
  Future<bool> isAvailable();

  /// Get items that have been modified since a specific timestamp
  Future<Map<String, Map<String, dynamic>>> getModifiedSince(
      DateTime timestamp);

  /// Close the remote storage connection
  Future<void> close();
}
