import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class GeofenceService extends ChangeNotifier {
  // Geofence center
  double? _geofenceLat;
  double? _geofenceLong;
  double _geofenceRadius = 500.0; // default 500m

  // Device position
  double _deviceLat = 0.0;
  double _deviceLong = 0.0;

  // State
  bool _isGeofenceSet = false;
  bool _isInsideGeofence = true;
  bool _wasInsideGeofence = true;
  double _distanceFromCenter = 0.0;
  bool _hasBreached = false;

  // Subscriptions
  StreamSubscription<DatabaseEvent>? _geofenceLatSub;
  StreamSubscription<DatabaseEvent>? _geofenceLongSub;
  StreamSubscription<DatabaseEvent>? _geofenceRadiusSub;
  StreamSubscription<DatabaseEvent>? _deviceLatSub;
  StreamSubscription<DatabaseEvent>? _deviceLongSub;

  late final DatabaseReference _dbRef;

  // Getters
  double? get geofenceLat => _geofenceLat;
  double? get geofenceLong => _geofenceLong;
  double get geofenceRadius => _geofenceRadius;
  double get deviceLat => _deviceLat;
  double get deviceLong => _deviceLong;
  bool get isGeofenceSet => _isGeofenceSet;
  bool get isInsideGeofence => _isInsideGeofence;
  double get distanceFromCenter => _distanceFromCenter;

  /// True when device has just transitioned from inside → outside.
  /// Consuming code should read this and reset it via [clearBreach].
  bool get hasBreached => _hasBreached;

  GeofenceService() {
    _initFirebase();
  }

  void _initFirebase() {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://vdb-poc-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _dbRef = db.ref('emylock-candy');

      // Listen to geofence coordinates
      _geofenceLatSub = _dbRef.child('geofence-lat').onValue.listen((event) {
        final val = _parseDouble(event.snapshot.value);
        if (val != null) {
          _geofenceLat = val;
          _updateGeofenceState();
        }
      });

      _geofenceLongSub = _dbRef.child('geofence-long').onValue.listen((event) {
        final val = _parseDouble(event.snapshot.value);
        if (val != null) {
          _geofenceLong = val;
          _updateGeofenceState();
        }
      });

      _geofenceRadiusSub =
          _dbRef.child('geofence-radius').onValue.listen((event) {
        final val = _parseDouble(event.snapshot.value);
        if (val != null && val > 0) {
          _geofenceRadius = val;
          _updateGeofenceState();
        }
      });

      // Listen to device location
      _deviceLatSub =
          _dbRef.child('latest_location/latitude').onValue.listen((event) {
        final val = _parseDouble(event.snapshot.value);
        if (val != null) {
          _deviceLat = val;
          _updateGeofenceState();
        }
      });

      _deviceLongSub =
          _dbRef.child('latest_location/longitude').onValue.listen((event) {
        final val = _parseDouble(event.snapshot.value);
        if (val != null) {
          _deviceLong = val;
          _updateGeofenceState();
        }
      });
    } catch (e) {
      debugPrint('GeofenceService init error: $e');
    }
  }

  void _updateGeofenceState() {
    if (_geofenceLat == null || _geofenceLong == null) {
      _isGeofenceSet = false;
      _isInsideGeofence = true;
      _hasBreached = false;
      notifyListeners();
      return;
    }

    _isGeofenceSet = true;
    _distanceFromCenter = _haversineDistance(
      _deviceLat,
      _deviceLong,
      _geofenceLat!,
      _geofenceLong!,
    );

    _wasInsideGeofence = _isInsideGeofence;
    _isInsideGeofence = _distanceFromCenter <= _geofenceRadius;

    // Detect breach: was inside, now outside
    if (_wasInsideGeofence && !_isInsideGeofence) {
      _hasBreached = true;
      debugPrint(
          'GEOFENCE BREACH! Distance: ${_distanceFromCenter.toStringAsFixed(0)}m > ${_geofenceRadius.toStringAsFixed(0)}m');
    }

    notifyListeners();
  }

  /// Clear the breach flag after the alert has been shown
  void clearBreach() {
    _hasBreached = false;
    // Don't notify — this is a silent reset
  }

  /// Save geofence to Firebase
  Future<void> setGeofence(double lat, double lng, double radius) async {
    try {
      await _dbRef.child('geofence-lat').set(lat);
      await _dbRef.child('geofence-long').set(lng);
      await _dbRef.child('geofence-radius').set(radius);
      debugPrint(
          'Geofence saved: ($lat, $lng) radius: ${radius.toStringAsFixed(0)}m');
    } catch (e) {
      debugPrint('Failed to save geofence: $e');
    }
  }

  /// Remove geofence from Firebase
  Future<void> clearGeofence() async {
    try {
      await _dbRef.child('geofence-lat').remove();
      await _dbRef.child('geofence-long').remove();
      await _dbRef.child('geofence-radius').remove();
      _geofenceLat = null;
      _geofenceLong = null;
      _isGeofenceSet = false;
      _isInsideGeofence = true;
      _hasBreached = false;
      notifyListeners();
      debugPrint('Geofence cleared');
    } catch (e) {
      debugPrint('Failed to clear geofence: $e');
    }
  }

  /// Haversine formula — returns distance in meters between two lat/lng points
  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  void dispose() {
    _geofenceLatSub?.cancel();
    _geofenceLongSub?.cancel();
    _geofenceRadiusSub?.cancel();
    _deviceLatSub?.cancel();
    _deviceLongSub?.cancel();
    super.dispose();
  }
}
