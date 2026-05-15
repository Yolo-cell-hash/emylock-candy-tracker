import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseLocationService extends ChangeNotifier {
  double _latitude = 19.02083;
  double _longitude = 72.84066;
  double _altitude = 0.0;
  double _accuracy = 0.0;
  int _timestamp = 0;
  String _timestampHuman = '';
  DateTime _lastUpdated = DateTime.now();
  bool _hasReceivedUpdate = false;
  StreamSubscription<DatabaseEvent>? _subscription;
  Timer? _refreshTimer;

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get altitude => _altitude;
  double get accuracy => _accuracy;
  int get timestamp => _timestamp;
  String get timestampHuman => _timestampHuman;
  DateTime get lastUpdated => _lastUpdated;
  bool get hasReceivedUpdate => _hasReceivedUpdate;

  /// Human-readable time since last update
  String get lastSeenText {
    if (!_hasReceivedUpdate) return 'Waiting for data…';
    final diff = DateTime.now().difference(_lastUpdated);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  FirebaseLocationService() {
    _startListening();
    // Periodically refresh the relative "last seen" text
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasReceivedUpdate) notifyListeners();
    });
  }

  void _startListening() {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://vdb-poc-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      final ref = db.ref('emylock-candy/latest_location');

      _subscription = ref.onValue.listen(
        (DatabaseEvent event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            final newLat = _parseDouble(data['latitude']) ?? _latitude;
            final newLng = _parseDouble(data['longitude']) ?? _longitude;
            final newAlt = _parseDouble(data['altitude']) ?? _altitude;
            final newAcc = _parseDouble(data['accuracy']) ?? _accuracy;
            final newTs = _parseInt(data['timestamp']) ?? _timestamp;
            final newTsHuman =
                (data['timestamp_human'] as String?) ?? _timestampHuman;

            final hasChanged = newLat != _latitude ||
                newLng != _longitude ||
                newAlt != _altitude ||
                newTs != _timestamp;

            _latitude = newLat;
            _longitude = newLng;
            _altitude = newAlt;
            _accuracy = newAcc;
            _timestamp = newTs;
            _timestampHuman = newTsHuman;

            if (hasChanged || !_hasReceivedUpdate) {
              _lastUpdated = DateTime.now();
              _hasReceivedUpdate = true;
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('Firebase location error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize Firebase location listener: $e');
    }
  }

  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
