/// Live background location tracking with server sync.
///
/// This library provides [LiveLocationService] for continuous location tracking
/// with automatic server synchronization, offline support, and retry logic.
/// Works even when the app is terminated using native background services.
///
/// See [LiveLocationService] for usage examples and API documentation.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:location_tracking/location_tracking.dart';

/// Configuration for live location tracking with server sync.
///
/// Example:
/// ```dart
/// final config = LiveLocationConfig(
///   apiBaseUrl: 'https://api.example.com',
///   apiEndpoint: '/api/v1/locations',
///   updateIntervalSeconds: 10,
///   distanceFilterMeters: 10,
///   syncIntervalMinutes: 5,
///   maxRetryAttempts: 3,
/// );
/// ```
class LiveLocationConfig {
  /// Base URL for the API server
  final String apiBaseUrl;

  /// API endpoint for location updates (relative to baseUrl)
  final String apiEndpoint;

  /// Interval in seconds between location updates
  /// Default: 10 seconds
  final int updateIntervalSeconds;

  /// Minimum distance in meters to trigger a location update
  /// Default: 10 meters
  final double distanceFilterMeters;

  /// Interval in minutes between sync attempts
  /// Default: 5 minutes
  final int syncIntervalMinutes;

  /// Maximum number of retry attempts for failed syncs
  /// Default: 3
  final int maxRetryAttempts;

  /// Timeout in seconds for API requests
  /// Default: 30 seconds
  final int apiTimeoutSeconds;

  /// Optional authorization token for API requests
  final String? authToken;

  /// Optional custom headers for API requests
  final Map<String, String>? customHeaders;

  /// Android-specific settings
  final AndroidSettings androidSettings;

  /// iOS-specific settings
  final IOSSettings iosSettings;

  const LiveLocationConfig({
    required this.apiBaseUrl,
    required this.apiEndpoint,
    this.updateIntervalSeconds = 10,
    this.distanceFilterMeters = 10,
    this.syncIntervalMinutes = 5,
    this.maxRetryAttempts = 3,
    this.apiTimeoutSeconds = 30,
    this.authToken,
    this.customHeaders,
    this.androidSettings = const AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      interval: 10,
      distanceFilter: 10,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationTitle: 'Location Tracking',
        notificationMsg: 'Tracking your location in background',
      ),
    ),
    this.iosSettings = const IOSSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      distanceFilter: 10,
      showsBackgroundLocationIndicator: true,
      stopWithTerminate: false,
    ),
  });

  /// Converts config to a map for passing to native code
  Map<String, dynamic> toMap() {
    return {
      'apiBaseUrl': apiBaseUrl,
      'apiEndpoint': apiEndpoint,
      'updateIntervalSeconds': updateIntervalSeconds,
      'distanceFilterMeters': distanceFilterMeters,
      'syncIntervalMinutes': syncIntervalMinutes,
      'maxRetryAttempts': maxRetryAttempts,
      'apiTimeoutSeconds': apiTimeoutSeconds,
      'authToken': authToken,
      'customHeaders': customHeaders,
    };
  }
}

/// Main service class for live background location tracking with server sync.
///
/// [LiveLocationService] provides a high-level API for continuous location tracking
/// that works even when the app is terminated. It includes:
/// - Automatic server synchronization
/// - Offline support with local storage
/// - Retry logic for failed syncs
/// - Battery-efficient tracking
///
/// Example usage:
/// ```dart
/// final service = LiveLocationService();
///
/// // Configure the service
/// final config = LiveLocationConfig(
///   apiBaseUrl: 'https://api.example.com',
///   apiEndpoint: '/api/v1/locations',
/// );
///
/// // Start tracking
/// await service.start(
///   config: config,
///   onLocation: (location) {
///     print('Location: ${location.latitude}, ${location.longitude}');
///   },
///   onSync: (count) {
///     print('Synced $count locations');
///   },
///   onError: (error) {
///     print('Error: $error');
///   },
/// );
///
/// // Check status
/// bool isRunning = await service.isTracking();
///
/// // Stop tracking
/// await service.stop();
/// ```
class LiveLocationService {
  static final LiveLocationService _instance = LiveLocationService._internal();

  factory LiveLocationService() => _instance;

  LiveLocationService._internal();

  bool _isInitialized = false;
  bool _isTracking = false;
  LiveLocationConfig? _currentConfig;

  /// Callback for location updates
  void Function(LocationDto)? _onLocation;

  /// Callback for errors
  void Function(String error)? _onError;

  /// Initialize the service
  ///
  /// This must be called before [start]. It sets up the native background
  /// location tracking service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await BackgroundLocator.initialize();
      _isInitialized = true;
      debugPrint('LiveLocationService initialized');
    } catch (e) {
      debugPrint('Failed to initialize LiveLocationService: $e');
      rethrow;
    }
  }

  /// Start live location tracking with server sync
  ///
  /// Parameters:
  /// - [config]: Configuration for tracking and sync behavior
  /// - [onLocation]: Callback invoked for each location update
  /// - [onError]: Optional callback invoked when errors occur
  ///
  /// Throws [StateError] if already tracking
  /// Throws [Exception] if location permissions are denied
  Future<void> start({
    required LiveLocationConfig config,
    required void Function(LocationDto) onLocation,
    void Function(String error)? onError,
  }) async {
    if (_isTracking) {
      throw StateError('Location tracking is already active');
    }

    if (!_isInitialized) {
      await initialize();
    }

    _currentConfig = config;
    _onLocation = onLocation;
    _onError = onError;

    try {
      // Register location updates with the native service
      await BackgroundLocator.registerLocationUpdate(
        _handleLocationUpdate,
        initCallback: _handleInit,
        initDataCallback: config.toMap(),
        disposeCallback: _handleDispose,
        androidSettings: config.androidSettings,
        iosSettings: config.iosSettings,
      );

      _isTracking = true;
      debugPrint('Live location tracking started');
    } catch (e) {
      _onError?.call('Failed to start tracking: $e');
      debugPrint('Failed to start location tracking: $e');
      rethrow;
    }
  }

  /// Stop location tracking
  ///
  /// Stops the background location service and cleans up resources.
  Future<void> stop() async {
    if (!_isTracking) return;

    try {
      await BackgroundLocator.unRegisterLocationUpdate();
      _isTracking = false;
      _currentConfig = null;
      _onLocation = null;
      _onError = null;
      debugPrint('Live location tracking stopped');
    } catch (e) {
      debugPrint('Failed to stop location tracking: $e');
      rethrow;
    }
  }

  /// Check if location tracking is currently active
  Future<bool> isTracking() async {
    return await BackgroundLocator.isServiceRunning();
  }

  /// Update the notification text (Android only)
  ///
  /// Dynamically updates the notification shown while tracking in background.
  Future<void> updateNotification({
    String? title,
    String? message,
    String? bigMessage,
  }) async {
    await BackgroundLocator.updateNotificationText(
      title: title,
      msg: message,
      bigMsg: bigMessage,
    );
  }

  /// Handle location updates from the native service
  void _handleLocationUpdate(LocationDto location) {
    debugPrint('Location update: ${location.latitude}, ${location.longitude}');
    _onLocation?.call(location);
  }

  /// Handle service initialization
  void _handleInit(Map<String, dynamic> data) {
    debugPrint('Location service initialized with config: $data');
  }

  /// Handle service disposal
  void _handleDispose() {
    debugPrint('Location service disposed');
    _isTracking = false;
  }

  /// Get current configuration
  LiveLocationConfig? get config => _currentConfig;
}
