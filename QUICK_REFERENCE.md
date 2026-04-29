# Quick Reference - Live Location Service

## 🚀 5-Minute Setup

### 1. Add Dependency
```yaml
dependencies:
  location_tracking: ^2.1.2
  permission_handler: ^12.0.0
```

### 2. Configure Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location for tracking</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### 3. Basic Implementation

```dart
import 'package:location_tracking/location_tracking.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTracker {
  final service = LiveLocationService();
  
  Future<void> start() async {
    // Request permissions
    await Permission.locationAlways.request();
    
    // Configure
    final config = LiveLocationConfig(
      apiBaseUrl: 'https://api.yourapp.com',
      apiEndpoint: '/api/v1/locations',
    );
    
    // Start
    await service.start(
      config: config,
      onLocation: (loc) => print('📍 $loc'),
    );
  }
  
  Future<void> stop() => service.stop();
}
```

---

## 📋 Common Configurations

### Rider App (High Accuracy)
```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.rideshare.com',
  apiEndpoint: '/api/v1/drivers/123/location',
  updateIntervalSeconds: 5,
  distanceFilterMeters: 10,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.NAVIGATION,
    interval: 5,
  ),
)
```

### Delivery App (Balanced)
```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.delivery.com',
  apiEndpoint: '/api/v1/orders/456/tracking',
  updateIntervalSeconds: 15,
  distanceFilterMeters: 20,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.BALANCED,
    interval: 15,
  ),
)
```

### Battery Saver Mode
```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.yourapp.com',
  apiEndpoint: '/api/v1/locations',
  updateIntervalSeconds: 30,
  distanceFilterMeters: 50,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.BALANCED,
    interval: 30,
  ),
)
```

---

## 🎯 API Endpoints

### Expected Request Format
```json
POST /api/v1/locations
{
  "locations": [
    {
      "latitude": 37.7749,
      "longitude": -122.4194,
      "accuracy": 10.5,
      "timestamp": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

### Expected Response
```json
{
  "success": true,
  "received": 1
}
```

---

## 🔧 Common Tasks

### Check if Tracking
```dart
bool isTracking = await service.isTracking();
```

### Update Notification (Android)
```dart
await service.updateNotification(
  title: 'On a Ride',
  message: 'Tracking active',
);
```

### With Authentication
```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.yourapp.com',
  apiEndpoint: '/api/v1/locations',
  authToken: 'Bearer your-token-here',
)
```

### With Custom Headers
```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.yourapp.com',
  apiEndpoint: '/api/v1/locations',
  customHeaders: {
    'X-User-ID': '123',
    'X-App-Version': '1.0.0',
  },
)
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Location not updating | Check GPS enabled, test outdoors |
| Stops when app closed | Verify background permissions granted |
| High battery drain | Increase interval, use BALANCED accuracy |
| API sync failing | Check network, verify endpoint URL |

---

## 📖 Full Documentation

- [Complete Guide](LIVE_LOCATION_GUIDE.md) - Detailed documentation
- [Example App](example/lib/live_location_example.dart) - Working example
- [Main README](README.md) - Package overview

---

## 💡 Pro Tips

1. **Test outdoors** - GPS doesn't work well indoors
2. **Start with BALANCED** accuracy - Switch to NAVIGATION only when needed
3. **Use distance filter** - Reduces battery drain significantly
4. **Handle errors gracefully** - Network issues are common
5. **Inform users** - Always explain why you need background location

---

## 🆘 Need Help?

- 📖 [Full Documentation](LIVE_LOCATION_GUIDE.md)
- 🐛 [Report Issues](https://github.com/sombathdanet/location-tracking/issues)
- 💬 [Discussions](https://github.com/sombathdanet/location-tracking/discussions)
