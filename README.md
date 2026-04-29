# location_tracking

[![pub package](https://img.shields.io/pub/v/location_tracking.svg)](https://pub.dev/packages/location_tracking)
[![Platform Compliance](https://img.shields.io/badge/Platform-Compliant-green.svg)](PLATFORM_COMPLIANCE.md)

A Flutter plugin for receiving location updates even when the app is terminated. Works on both iOS and Android platforms with full support for background execution.

**✅ Fully compliant with [Apple](https://developer.apple.com/documentation/corelocation) and [Google](https://developer.android.com/training/location) official recommendations.**

## Features

- 🌍 Continuous location tracking in background
- 📱 Works even when app is killed/terminated
- 🔋 Battery-efficient location updates
- 🎯 Configurable accuracy and update intervals
- 🔔 Android notification support
- 📍 Distance filter to reduce unnecessary updates
- 🔄 Auto-restart after device reboot (Android)
- ⚙️ Platform-specific settings for iOS and Android
- 🚀 **NEW:** Live location service with automatic server sync
- 💾 **NEW:** Offline support with local storage and retry logic
- 🔄 **NEW:** Easy-to-use configuration for rider/delivery apps

## Platform Support

| Platform | Support | Min Version |
|----------|---------|-------------|
| Android  | ✅ Full | API 21+     |
| iOS      | ✅ Full | iOS 11.0+   |
| Web      | ❌ Not supported | - |
| Windows  | ❌ Not supported | - |
| macOS    | ❌ Not supported | - |
| Linux    | ❌ Not supported | - |

**✅ Fully compliant with [Apple](https://developer.apple.com/documentation/corelocation) and [Google](https://developer.android.com/training/location) official recommendations.**

**Note:** Web, Windows, macOS, and Linux platforms are not supported as they don't have native background location tracking capabilities.

See [PLATFORM_COMPLIANCE.md](PLATFORM_COMPLIANCE.md) for detailed compliance verification.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  location_tracking: ^2.1.1
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
</manifest>
```

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when in use</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location in background</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location in background</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
</array>
```

## Quick Start

<<<<<<< HEAD
### Option 1: Live Location Service (Recommended for Rider/Delivery Apps)

For apps that need continuous location tracking with automatic server synchronization:

```dart
import 'package:location_tracking/location_tracking.dart';

// Configure the service
final config = LiveLocationConfig(
  apiBaseUrl: 'https://api.yourapp.com',
  apiEndpoint: '/api/v1/locations',
  updateIntervalSeconds: 10,
  distanceFilterMeters: 10,
);

// Start tracking
final service = LiveLocationService();
await service.start(
  config: config,
  onLocation: (location) {
    print('📍 ${location.latitude}, ${location.longitude}');
  },
  onSync: (count) {
    print('✅ Synced $count locations');
  },
  onError: (error) {
    print('❌ Error: $error');
  },
);

// Stop tracking
await service.stop();
```

**📖 [Complete Live Location Guide](LIVE_LOCATION_GUIDE.md)** - Detailed documentation with examples for rider apps, delivery apps, and more.

### Option 2: Basic Location Tracking

For apps that need manual control over location updates:
=======
### Quick Start
>>>>>>> db58829 (remove-md)

```dart
import 'package:location_tracking/background_locator.dart';
import 'package:location_tracking/location_dto.dart';

// Initialize
await BackgroundLocator.initialize();

// Start tracking
await BackgroundLocator.registerLocationUpdate(
  (LocationDto location) {
    print('Lat: ${location.latitude}, Lng: ${location.longitude}');
  },
);

// Stop tracking
await BackgroundLocator.unRegisterLocationUpdate();
```

### Full Example with Callbacks

```dart
// Initialize the plugin
await BackgroundLocator.initialize();

// Register with callbacks
await BackgroundLocator.registerLocationUpdate(
  locationCallback,
  initCallback: initCallback,
  disposeCallback: disposeCallback,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.NAVIGATION,
    interval: 5,
    distanceFilter: 0,
    androidNotificationSettings: AndroidNotificationSettings(
      notificationChannelName: 'Location tracking',
      notificationTitle: 'Tracking Active',
      notificationMsg: 'Location tracking in background',
    ),
  ),
  iosSettings: IOSSettings(
    accuracy: LocationAccuracy.NAVIGATION,
    distanceFilter: 0,
  ),
);

// Callbacks (must be top-level or static)
@pragma('vm:entry-point')
static void locationCallback(LocationDto location) {
  print('Location: ${location.latitude}, ${location.longitude}');
}

@pragma('vm:entry-point')
static void initCallback(Map<dynamic, dynamic> params) {
  print('Service initialized');
}

@pragma('vm:entry-point')
static void disposeCallback() {
  print('Service disposed');
}
```

## Configuration Options

### Android Settings

- `accuracy`: Location accuracy (POWERLOW, LOW, BALANCED, HIGH, NAVIGATION)
- `interval`: Update interval in seconds
- `distanceFilter`: Minimum distance (meters) to trigger update
- `androidNotificationSettings`: Notification configuration for foreground service

### iOS Settings

- `accuracy`: Location accuracy
- `distanceFilter`: Minimum distance (meters) to trigger update
- `showsBackgroundLocationIndicator`: Show blue bar indicator
- `stopWithTerminate`: Stop tracking when app terminates

## Additional Resources

For more detailed information, check out:
- 📖 [Live Location Guide](LIVE_LOCATION_GUIDE.md) - Complete guide for rider/delivery apps
- 💻 [Example app](example/) - Complete working examples
- 📚 [API Documentation](https://pub.dev/documentation/location_tracking/latest/)
- ✅ [Platform Compliance](PLATFORM_COMPLIANCE.md) - Verification of Apple/Google compliance
- ✅ [Apple Recommendations Verified](APPLE_RECOMMENDATIONS_VERIFIED.md) - Line-by-line iOS verification
- 🔋 [iOS Battery Reality](IOS_BATTERY_REALITY.md) - Honest analysis of iOS battery impact

## Use Cases

### Rider/Delivery Apps
Use `LiveLocationService` for automatic tracking with server sync:
- Real-time driver location updates
- Offline support with automatic retry
- Battery-efficient tracking
- Easy configuration

See [LIVE_LOCATION_GUIDE.md](LIVE_LOCATION_GUIDE.md) for complete implementation guide.

### Custom Location Handling
Use `BackgroundLocator` for manual control:
- Custom location processing
- Local-only tracking
- Integration with existing systems

## Important Notes

- Callback functions must be top-level functions or static methods
- Use `@pragma('vm:entry-point')` annotation on callbacks
- Request location permissions before starting tracking
- On Android 10+, background location permission requires user approval
- iOS requires "Always" location permission for background tracking

## Troubleshooting

### Android
- Ensure all required permissions are in AndroidManifest.xml
- Check that notification settings are properly configured
- Verify foreground service is running

### iOS
- Ensure Info.plist has all required location keys
- Check that background modes include "location"
- Verify "Always" permission is granted

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributors

Thanks to all who have contributed to this plugin:
* Original creators and maintainers of background_locator
* [Yukams](https://github.com/Yukams) - background_locator_2 fork
* [Rekab](https://github.com/rekabhq) - Original background_locator creator
* All other contributors who have helped improve this package

## Credits

This package is based on the excellent work of the background_locator community. Special thanks to:
- Natnael Seyoum and Tekletsadik Aknaw for background_locator_3
- Yukams for background_locator_2
- The original Rekab team for creating background_locator
