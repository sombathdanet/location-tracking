import 'package:flutter/material.dart';
import 'package:location_tracking/location_tracking.dart';
import 'package:permission_handler/permission_handler.dart';

/// Example app demonstrating LiveLocationService usage
void main() => runApp(LiveLocationExampleApp());

class LiveLocationExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Tracking',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LiveLocationScreen(),
    );
  }
}

class LiveLocationScreen extends StatefulWidget {
  @override
  _LiveLocationScreenState createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  final LiveLocationService _locationService = LiveLocationService();
  
  bool _isTracking = false;
  LocationDto? _lastLocation;
  int _locationCount = 0;
  int _syncCount = 0;
  String? _errorMessage;
  
  // Configuration
  final TextEditingController _apiUrlController = 
      TextEditingController(text: 'https://api.example.com');
  final TextEditingController _endpointController = 
      TextEditingController(text: '/api/v1/locations');
  final TextEditingController _intervalController = 
      TextEditingController(text: '10');
  final TextEditingController _distanceController = 
      TextEditingController(text: '10');

  @override
  void dispose() {
    _apiUrlController.dispose();
    _endpointController.dispose();
    _intervalController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracking'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            SizedBox(height: 16),
            _buildConfigurationCard(),
            SizedBox(height: 16),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isTracking ? Icons.location_on : Icons.location_off,
                  color: _isTracking ? Colors.green : Colors.red,
                  size: 32,
                ),
                SizedBox(width: 8),
                Text(
                  _isTracking ? 'Tracking Active' : 'Tracking Stopped',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isTracking ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Location info
            if (_lastLocation != null) ...[
              _buildInfoRow('Latitude', _lastLocation!.latitude.toStringAsFixed(6)),
              _buildInfoRow('Longitude', _lastLocation!.longitude.toStringAsFixed(6)),
              _buildInfoRow('Accuracy', '${_lastLocation!.accuracy.toStringAsFixed(1)}m'),
              if (_lastLocation!.speed != null)
                _buildInfoRow('Speed', '${_lastLocation!.speed!.toStringAsFixed(1)} m/s'),
              if (_lastLocation!.altitude != null)
                _buildInfoRow('Altitude', '${_lastLocation!.altitude!.toStringAsFixed(1)}m'),
            ] else
              Text('No location data yet', style: TextStyle(color: Colors.grey)),
            
            Divider(height: 24),
            
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Locations', _locationCount.toString()),
                _buildStatColumn('Synced', _syncCount.toString()),
              ],
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _apiUrlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              enabled: !_isTracking,
            ),
            SizedBox(height: 12),
            
            TextField(
              controller: _endpointController,
              decoration: InputDecoration(
                labelText: 'API Endpoint',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.api),
              ),
              enabled: !_isTracking,
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _intervalController,
                    decoration: InputDecoration(
                      labelText: 'Interval (seconds)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isTracking,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    decoration: InputDecoration(
                      labelText: 'Distance (meters)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isTracking,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isTracking ? null : _startTracking,
          icon: Icon(Icons.play_arrow),
          label: Text('Start Tracking'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(16),
            backgroundColor: Colors.green,
          ),
        ),
        SizedBox(height: 12),
        
        ElevatedButton.icon(
          onPressed: _isTracking ? _stopTracking : null,
          icon: Icon(Icons.stop),
          label: Text('Stop Tracking'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(16),
            backgroundColor: Colors.red,
          ),
        ),
        SizedBox(height: 12),
        
        OutlinedButton.icon(
          onPressed: _resetStats,
          icon: Icon(Icons.refresh),
          label: Text('Reset Statistics'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _startTracking() async {
    // Request permissions
    if (!await _requestLocationPermissions()) {
      _showError('Location permission denied');
      return;
    }

    // Validate configuration
    if (_apiUrlController.text.isEmpty || _endpointController.text.isEmpty) {
      _showError('Please enter API URL and endpoint');
      return;
    }

    try {
      final config = LiveLocationConfig(
        apiBaseUrl: _apiUrlController.text,
        apiEndpoint: _endpointController.text,
        updateIntervalSeconds: int.tryParse(_intervalController.text) ?? 10,
        distanceFilterMeters: double.tryParse(_distanceController.text) ?? 10,
        syncIntervalMinutes: 5,
        maxRetryAttempts: 3,
        
        androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: int.tryParse(_intervalController.text) ?? 10,
          distanceFilter: double.tryParse(_distanceController.text) ?? 10,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationTitle: 'Location Tracking Active',
            notificationMsg: 'Tracking your location in background',
          ),
        ),
        
        iosSettings: IOSSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          distanceFilter: double.tryParse(_distanceController.text) ?? 10,
          showsBackgroundLocationIndicator: true,
          stopWithTerminate: false,
        ),
      );

      await _locationService.start(
        config: config,
        onLocation: _handleLocationUpdate,
        onSync: _handleSync,
        onError: _handleError,
      );

      setState(() {
        _isTracking = true;
        _errorMessage = null;
      });

      _showSuccess('Location tracking started');
    } catch (e) {
      _showError('Failed to start tracking: $e');
    }
  }

  Future<void> _stopTracking() async {
    try {
      await _locationService.stop();
      setState(() => _isTracking = false);
      _showSuccess('Location tracking stopped');
    } catch (e) {
      _showError('Failed to stop tracking: $e');
    }
  }

  void _handleLocationUpdate(LocationDto location) {
    setState(() {
      _lastLocation = location;
      _locationCount++;
      _errorMessage = null;
    });
  }

  void _handleSync(int count) {
    setState(() {
      _syncCount += count;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Synced $count locations'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleError(String error) {
    setState(() => _errorMessage = error);
  }

  void _resetStats() {
    setState(() {
      _locationCount = 0;
      _syncCount = 0;
      _lastLocation = null;
      _errorMessage = null;
    });
  }

  Future<bool> _requestLocationPermissions() async {
    var status = await Permission.location.request();
    
    if (status.isGranted) {
      // Request background location permission
      status = await Permission.locationAlways.request();
    }
    
    return status.isGranted;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Live Location Tracking'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This example demonstrates background location tracking with server sync.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features:'),
              Text('• Tracks location in background'),
              Text('• Works when app is closed'),
              Text('• Automatic server sync'),
              Text('• Offline support'),
              Text('• Battery efficient'),
              SizedBox(height: 16),
              Text(
                'Note: Make sure to configure your API endpoint before starting.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
