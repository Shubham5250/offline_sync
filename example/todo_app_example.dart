import 'package:flutter/material.dart';
import 'package:flutter_data_sync_manager/flutter_data_sync_manager.dart';

/// Complete example showing how to use Offline Sync in a Todo app
class TodoAppExample extends StatefulWidget {
  const TodoAppExample({super.key});

  @override
  State<TodoAppExample> createState() => _TodoAppExampleState();
}

class _TodoAppExampleState extends State<TodoAppExample> {
  late SyncManager syncManager;
  List<Todo> todos = [];
  bool isSyncing = false;
  String lastSyncStatus = 'Not synced yet';

  @override
  void initState() {
    super.initState();
    _initializeSync();
  }

  /// Step 1: Initialize the sync manager
  Future<void> _initializeSync() async {
    // Create sync manager with your storage adapters
    syncManager = SyncManager(
      localDb: HiveAdapter(boxName: 'todos'), // Local storage
      remoteApi: TodoApiAdapter(), // Your custom remote API
      config: SyncConfig.offlineFirst(), // Optimized for offline-first
    );

    // Initialize the sync manager
    await syncManager.initialize();
    
    // Load initial data
    await _loadTodos();
    
    // Perform initial sync
    await _performSync();
  }

  /// Step 2: Load todos from local storage
  Future<void> _loadTodos() async {
    final localData = await syncManager.localDb.getAll();
    setState(() {
      todos = localData.values
          .map((data) => Todo.fromJson(data))
          .toList();
    });
  }

  /// Step 3: Add a new todo (works offline!)
  Future<void> _addTodo(String title) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      completed: false,
      createdAt: DateTime.now(),
    );

    // Save to local storage immediately (works offline)
    await syncManager.localDb.save(todo.id, todo.toJson());
    
    // Update UI immediately
    setState(() {
      todos.add(todo);
    });

    // Sync in background (will happen when network is available)
    _performSync();
  }

  /// Step 4: Toggle todo completion
  Future<void> _toggleTodo(String id) async {
    final todoIndex = todos.indexWhere((todo) => todo.id == id);
    if (todoIndex == -1) return;

    // Update local data
    todos[todoIndex] = todos[todoIndex].copyWith(
      completed: !todos[todoIndex].completed,
    );

    // Save to local storage
    await syncManager.localDb.save(id, todos[todoIndex].toJson());
    
    setState(() {});

    // Sync changes
    _performSync();
  }

  /// Step 5: Perform sync operation
  Future<void> _performSync() async {
    if (isSyncing) return;

    setState(() {
      isSyncing = true;
    });

    try {
      // This is the magic! One line handles everything:
      // - Uploads local changes to remote
      // - Downloads remote changes to local
      // - Resolves conflicts automatically
      // - Retries on failure
      final result = await syncManager.syncWithRetry();

      setState(() {
        lastSyncStatus = result.success
            ? 'Last sync: ${result.localToRemoteCount} up, ${result.remoteToLocalCount} down, ${result.conflictCount} conflicts'
            : 'Sync failed: ${result.error}';
      });

      // Reload data after sync to get any new changes
      if (result.success) {
        await _loadTodos();
      }
    } catch (e) {
      setState(() {
        lastSyncStatus = 'Sync error: $e';
      });
    } finally {
      setState(() {
        isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App with Offline Sync'),
        actions: [
          IconButton(
            icon: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: isSyncing ? null : _performSync,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sync status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              lastSyncStatus,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          
          // Todo list
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text('Created: ${todo.createdAt.toString()}'),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: (_) => _toggleTodo(todo.id),
                  ),
                  leading: Icon(
                    todo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: todo.completed ? Colors.green : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter todo title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    syncManager.close();
    super.dispose();
  }
}

/// Todo data model
class Todo {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Custom remote adapter for Todo API
class TodoApiAdapter implements RemoteAdapter {
  final Map<String, Map<String, dynamic>> _remoteData = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  Future<void> initialize() async {
    // Simulate some initial remote data
    _remoteData['todo_1'] = {
      'id': 'todo_1',
      'title': 'Buy groceries',
      'completed': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    };
    _timestamps['todo_1'] = DateTime.now().subtract(const Duration(hours: 2));
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAll() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    return Map<String, Map<String, dynamic>>.from(_remoteData);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _remoteData[key];
  }

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _remoteData[key] = Map<String, dynamic>.from(data);
    _timestamps[key] = DateTime.now();
  }

  @override
  Future<void> saveAll(Map<String, Map<String, dynamic>> items) async {
    for (final entry in items.entries) {
      await save(entry.key, entry.value);
    }
  }

  @override
  Future<void> delete(String key) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _remoteData.remove(key);
    _timestamps.remove(key);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  @override
  Future<bool> exists(String key) async {
    return _remoteData.containsKey(key);
  }

  @override
  Future<DateTime?> getLastModified(String key) async {
    return _timestamps[key];
  }

  @override
  Future<bool> isAvailable() async {
    // Simulate network connectivity check
    return true; // In real app, check actual network status
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getModifiedSince(DateTime timestamp) async {
    final result = <String, Map<String, dynamic>>{};
    for (final entry in _timestamps.entries) {
      if (entry.value.isAfter(timestamp)) {
        result[entry.key] = _remoteData[entry.key]!;
      }
    }
    return result;
  }

  @override
  Future<void> close() async {
    // Cleanup if needed
  }
}
