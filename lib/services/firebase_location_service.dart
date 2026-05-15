import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseLocationService extends ChangeNotifier {
  double _latitude = 19.02083;
  double _longitude = 72.84066;
  DateTime _lastUpdated = DateTime.now();
  bool _hasReceivedUpdate = false;
  StreamSubscription<DatabaseEvent>? _subscription;

  double get latitude => _latitude;
  double get longitude => _longitude;
  DateTime get lastUpdated => _lastUpdated;
  bool get hasReceivedUpdate => _hasReceivedUpdate;

  /// Human-readable time since last update
  String get lastSeenText {
    final diff = DateTime.now().difference(_lastUpdated);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  FirebaseLocationService() {
    _startListening();
  }

  void _startListening() {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://vdb-poc-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      final ref = db.ref('emylock-candy');

      _subscription = ref.onValue.listen(
        (DatabaseEvent event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            final newLat = _parseDouble(data['latitude']) ?? _latitude;
            final newLng = _parseDouble(data['longitude']) ?? _longitude;

            if (newLat != _latitude || newLng != _longitude) {
              _latitude = newLat;
              _longitude = newLng;
              _lastUpdated = DateTime.now();
              _hasReceivedUpdate = true;
              notifyListeners();
            } else if (!_hasReceivedUpdate) {
              // First load — still notify to render initial position
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
