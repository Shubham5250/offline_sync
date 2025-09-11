import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity status and provides callbacks
class NetworkStatusMonitor {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isConnected = false;
  final List<VoidCallback> _onConnectedCallbacks = [];
  final List<VoidCallback> _onDisconnectedCallbacks = [];

  /// Current network connection status
  bool get isConnected => _isConnected;

  /// Initialize the network monitor
  Future<void> initialize() async {
    // Check initial connectivity status
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Add callback to be called when network becomes available
  void onConnected(VoidCallback callback) {
    _onConnectedCallbacks.add(callback);
  }

  /// Add callback to be called when network becomes unavailable
  void onDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.add(callback);
  }

  /// Remove a connected callback
  void removeOnConnectedCallback(VoidCallback callback) {
    _onConnectedCallbacks.remove(callback);
  }

  /// Remove a disconnected callback
  void removeOnDisconnectedCallback(VoidCallback callback) {
    _onDisconnectedCallbacks.remove(callback);
  }

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return _hasValidConnection(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    final wasConnected = _isConnected;
    _isConnected = _hasValidConnection(connectivityResult);

    // Trigger callbacks only on status change
    if (!wasConnected && _isConnected) {
      // Network became available
      for (final callback in _onConnectedCallbacks) {
        callback();
      }
    } else if (wasConnected && !_isConnected) {
      // Network became unavailable
      for (final callback in _onDisconnectedCallbacks) {
        callback();
      }
    }
  }

  bool _hasValidConnection(ConnectivityResult connectivityResult) {
    // Check if the connectivity result indicates a valid connection
    return connectivityResult == ConnectivityResult.mobile ||
           connectivityResult == ConnectivityResult.wifi ||
           connectivityResult == ConnectivityResult.ethernet ||
           connectivityResult == ConnectivityResult.vpn ||
           connectivityResult == ConnectivityResult.bluetooth ||
           connectivityResult == ConnectivityResult.other;
  }

  /// Dispose the network monitor and clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();
  }
}

/// Type definition for void callbacks
typedef VoidCallback = void Function();
