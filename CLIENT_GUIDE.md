# Client Implementation Guide - Live Location Tracking

## 🎯 What You Get

A production-ready location tracking solution that:
- ✅ Works when app is closed/terminated
- ✅ Tracks location in background
- ✅ Syncs to your server automatically
- ✅ Handles offline scenarios
- ✅ Battery efficient
- ✅ Easy to configure (5 lines of code)

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Add Package

```yaml
# pubspec.yaml
dependencies:
  location_tracking: ^2.2.0
  permission_handler: ^12.0.0+1
```

### Step 2: Configure Permissions

**Android** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** - Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track rides</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### Step 3: Implement

```dart
import 'package:location_tracking/location_tracking.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  final _service = LiveLocationService();
  
  Future<void> startTracking() async {
    // 1. Request permissions
    await Permission.locationAlways.request();
    
    // 2. Configure
    final config = LiveLocationConfig(
      apiBaseUrl: 'https://your-api.com',
      apiEndpoint: '/api/v1/locations',
      updateIntervalSeconds: 10,
      distanceFilterMeters: 10,
    );
    
    // 3. Start
    await _service.start(
      config: config,
      onLocation: (location) {
        print('📍 ${location.latitude}, ${location.longitude}');
      },
      onError: (error) {
        print('❌ $error');
      },
    );
  }
  
  Future<void> stopTracking() => _service.stop();
}
```

**That's it!** Your app is now tracking location in the background.

---

## 📡 API Integration

### What Your Backend Receives

```http
POST /api/v1/locations
Content-Type: application/json

{
  "locations": [
    {
      "latitude": 37.7749,
      "longitude": -122.4194,
      "accuracy": 10.5,
      "altitude": 15.0,
      "speed": 5.2,
      "heading": 180.0,
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

### With Authentication

```dart
final config = LiveLocationConfig(
  apiBaseUrl: 'https://your-api.com',
  apiEndpoint: '/api/v1/locations',
  authToken: 'Bearer your-jwt-token',
);
```

### With Custom Headers

```dart
final config = LiveLocationConfig(
  apiBaseUrl: 'https://your-api.com',
  apiEndpoint: '/api/v1/locations',
  customHeaders: {
    'X-User-ID': userId,
    'X-Device-ID': deviceId,
  },
);
```

---

## ⚙️ Configuration Options

### Basic Configuration

```dart
LiveLocationConfig(
  // Required
  apiBaseUrl: 'https://your-api.com',
  apiEndpoint: '/api/v1/locations',
  
  // Optional - defaults shown
  updateIntervalSeconds: 10,      // How often to check location
  distanceFilterMeters: 10,       // Minimum movement to record
  syncIntervalMinutes: 5,         // How often to sync to server
  maxRetryAttempts: 3,            // Retry failed syncs
  apiTimeoutSeconds: 30,          // API request timeout
)
```

### For Rider Apps (High Accuracy)

```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.rideshare.com',
  apiEndpoint: '/api/v1/drivers/$driverId/location',
  updateIntervalSeconds: 5,       // More frequent
  distanceFilterMeters: 10,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.NAVIGATION,  // Highest accuracy
    interval: 5,
    androidNotificationSettings: AndroidNotificationSettings(
      notificationTitle: '🚗 You\'re Online',
      notificationMsg: 'Ready to accept rides',
    ),
  ),
)
```

### For Delivery Apps (Balanced)

```dart
LiveLocationConfig(
  apiBaseUrl: 'https://api.delivery.com',
  apiEndpoint: '/api/v1/orders/$orderId/tracking',
  updateIntervalSeconds: 15,      // Less frequent
  distanceFilterMeters: 20,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.BALANCED,  // Balance battery/accuracy
    interval: 15,
  ),
)
```

### Battery Saver Mode

```dart
LiveLocationConfig(
  apiBaseUrl: 'https://your-api.com',
  apiEndpoint: '/api/v1/locations',
  updateIntervalSeconds: 30,      // Least frequent
  distanceFilterMeters: 50,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.BALANCED,
    interval: 30,
  ),
)
```

---

## 🎨 UI Integration

### Complete Example with UI

```dart
class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _service = LiveLocationService();
  bool _isTracking = false;
  LocationDto? _lastLocation;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracking')),
      body: Column(
        children: [
          // Status
          Text(_isTracking ? '🟢 Tracking' : '🔴 Stopped'),
          
          // Last location
          if (_lastLocation != null)
            Text('${_lastLocation!.latitude}, ${_lastLocation!.longitude}'),
          
          // Controls
          ElevatedButton(
            onPressed: _isTracking ? null : _startTracking,
            child: Text('Start'),
          ),
          ElevatedButton(
            onPressed: _isTracking ? _stopTracking : null,
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _startTracking() async {
    if (!await _requestPermissions()) {
      _showError('Permission denied');
      return;
    }
    
    final config = LiveLocationConfig(
      apiBaseUrl: 'https://your-api.com',
      apiEndpoint: '/api/v1/locations',
    );
    
    await _service.start(
      config: config,
      onLocation: (location) {
        setState(() => _lastLocation = location);
      },
      onError: (error) {
        _showError(error);
      },
    );
    
    setState(() => _isTracking = true);
  }
  
  Future<void> _stopTracking() async {
    await _service.stop();
    setState(() => _isTracking = false);
  }
  
  Future<bool> _requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      status = await Permission.locationAlways.request();
    }
    return status.isGranted;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

---

## 🔧 Common Use Cases

### 1. Start Tracking When User Goes Online

```dart
Future<void> goOnline() async {
  await _service.start(
    config: config,
    onLocation: _handleLocation,
  );
  
  // Update notification
  await _service.updateNotification(
    title: '🟢 You\'re Online',
    message: 'Ready to accept requests',
  );
}
```

### 2. Update Notification Based on Status

```dart
Future<void> onRideAccepted() async {
  await _service.updateNotification(
    title: '🚗 On a Ride',
    message: 'Tracking your trip',
  );
}

Future<void> onRideCompleted() async {
  await _service.updateNotification(
    title: '🟢 Available',
    message: 'Waiting for next ride',
  );
}
```

### 3. Adaptive Tracking

```dart
// High accuracy during active ride
Future<void> startRide() async {
  await _service.stop();
  
  final config = LiveLocationConfig(
    apiBaseUrl: 'https://api.com',
    apiEndpoint: '/locations',
    updateIntervalSeconds: 5,  // Frequent
    androidSettings: AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
    ),
  );
  
  await _service.start(config: config, onLocation: _handleLocation);
}

// Lower accuracy when idle
Future<void> endRide() async {
  await _service.stop();
  
  final config = LiveLocationConfig(
    apiBaseUrl: 'https://api.com',
    apiEndpoint: '/locations',
    updateIntervalSeconds: 30,  // Less frequent
    androidSettings: AndroidSettings(
      accuracy: LocationAccuracy.BALANCED,
    ),
  );
  
  await _service.start(config: config, onLocation: _handleLocation);
}
```

---

## 🐛 Troubleshooting

### Location Not Updating

**Check:**
1. Permissions granted (especially "Always" permission)
2. GPS enabled on device
3. Test outdoors (GPS doesn't work indoors)
4. Service is running: `await _service.isTracking()`

```dart
// Debug helper
Future<void> debugTracking() async {
  print('Tracking: ${await _service.isTracking()}');
  print('Location: ${await Permission.location.status}');
  print('Always: ${await Permission.locationAlways.status}');
}
```

### Stops When App Closed

**Android:**
- Verify `FOREGROUND_SERVICE` permission in manifest
- Check notification is showing
- Disable battery optimization for your app

**iOS:**
- Verify `UIBackgroundModes` includes `location`
- Ensure "Always" permission granted

### High Battery Drain

**Solutions:**
1. Increase `updateIntervalSeconds` (10-30)
2. Increase `distanceFilterMeters` (10-50)
3. Use `LocationAccuracy.BALANCED`

```dart
// Battery-friendly config
final config = LiveLocationConfig(
  apiBaseUrl: 'https://api.com',
  apiEndpoint: '/locations',
  updateIntervalSeconds: 30,
  distanceFilterMeters: 50,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.BALANCED,
  ),
);
```

---

## 📚 Additional Resources

- 📖 [Complete Guide](LIVE_LOCATION_GUIDE.md) - Detailed documentation
- 🚀 [Quick Reference](QUICK_REFERENCE.md) - Quick lookup
- 💻 [Example App](example/lib/live_location_example.dart) - Working code
- 📝 [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Technical details

---

## ✅ Checklist

Before going to production:

- [ ] Permissions configured (Android + iOS)
- [ ] API endpoint tested
- [ ] Authentication working
- [ ] Tested with app in foreground
- [ ] Tested with app in background
- [ ] Tested with app closed
- [ ] Tested offline scenario
- [ ] Battery drain acceptable
- [ ] Notification customized (Android)
- [ ] User informed about background tracking

---

## 🆘 Support

Need help?
- 📖 Read the [Complete Guide](LIVE_LOCATION_GUIDE.md)
- 💻 Check the [Example App](example/lib/live_location_example.dart)
- 🐛 [Report Issues](https://github.com/sombathdanet/location-tracking/issues)

---

**Version:** 2.2.0  
**License:** MIT  
**Status:** ✅ Production Ready
