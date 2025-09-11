/// Interface for local storage adapters
abstract class LocalAdapter {
  /// Initialize the local storage
  Future<void> initialize();

  /// Get all items from local storage
  Future<Map<String, Map<String, dynamic>>> getAll();

  /// Get a specific item by key
  Future<Map<String, dynamic>?> get(String key);

  /// Save an item to local storage
  Future<void> save(String key, Map<String, dynamic> data);

  /// Save multiple items to local storage
  Future<void> saveAll(Map<String, Map<String, dynamic>> items);

  /// Delete an item from local storage
  Future<void> delete(String key);

  /// Delete multiple items from local storage
  Future<void> deleteAll(List<String> keys);

  /// Check if an item exists in local storage
  Future<bool> exists(String key);

  /// Get the timestamp of when an item was last modified
  Future<DateTime?> getLastModified(String key);

  /// Update the last modified timestamp for an item
  Future<void> updateLastModified(String key, DateTime timestamp);

  /// Clear all data from local storage
  Future<void> clear();

  /// Get the total number of items in local storage
  Future<int> count();

  /// Close the local storage connection
  Future<void> close();
}
