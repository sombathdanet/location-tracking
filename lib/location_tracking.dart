/// A Flutter plugin for receiving location updates even when the app is terminated.
///
/// This plugin provides background location tracking on both iOS and Android platforms.
/// It supports continuous location updates, local storage, and server synchronization.
///
/// ## Features
///
/// - Background location tracking even when app is terminated
/// - Configurable update intervals and distance filters
/// - Local storage with Hive database
/// - Automatic server synchronization
/// - Platform-specific settings for Android and iOS
/// - Automatic stop on app background (optional)
///
/// ## Getting Started
///
/// ### Installation
///
/// Add to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   location_tracking: ^2.1.1
/// ```
///
/// ### Basic Usage
///
/// ```dart
/// import 'package:location_tracking/location_tracking.dart';
///
/// // Initialize the service
/// await BackgroundLocator.initialize();
///
/// // Register location updates
/// await BackgroundLocator.registerLocationUpdate(
///   (LocationDto location) {
///     print('Location: ${location.latitude}, ${location.longitude}');
///   },
///   androidSettings: AndroidSettings(
///     accuracy: LocationAccuracy.NAVIGATION,
///     interval: 5,
///   ),
///   iosSettings: IOSSettings(
///     accuracy: LocationAccuracy.NAVIGATION,
///   ),
/// );
///
/// // Check if tracking is running
/// bool isRunning = await BackgroundLocator.isServiceRunning();
///
/// // Stop tracking
/// await BackgroundLocator.unRegisterLocationUpdate();
/// ```
///
/// ## Platform Support
///
/// - **Android**: API level 21+
/// - **iOS**: iOS 11.0+
///
/// ## Permissions
///
/// ### Android
/// Add to `AndroidManifest.xml`:
/// ```xml
/// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
/// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
/// ```
///
/// ### iOS
/// Add to `Info.plist`:
/// ```xml
/// <key>NSLocationWhenInUseUsageDescription</key>
/// <string>This app needs your location to track it in the background</string>
/// <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
/// <string>This app needs your location to track it in the background</string>
/// ```
///
/// ## See Also
///
/// - [BackgroundLocator] - Main class for managing location tracking
/// - [LocationDto] - Data model for location information
/// - [AndroidSettings] - Android-specific configuration
/// - [IOSSettings] - iOS-specific configuration

library location_tracking;

export 'background_locator.dart';
export 'location_dto.dart';
export 'auto_stop_handler.dart';
export 'settings/android_settings.dart';
export 'settings/ios_settings.dart';
export 'settings/locator_settings.dart';
export 'keys.dart';
export 'live_location_service.dart';
