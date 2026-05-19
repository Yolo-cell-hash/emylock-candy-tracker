import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/firebase_location_service.dart';
import '../services/geofence_service.dart';
import '../theme/app_theme.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Editable geofence state
  LatLng? _editCenter;
  double _editRadius = 500.0; // in meters
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Initialize from existing geofence if set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final geo = context.read<GeofenceService>();
      final loc = context.read<FirebaseLocationService>();
      if (geo.isGeofenceSet && geo.geofenceLat != null) {
        setState(() {
          _editCenter = LatLng(geo.geofenceLat!, geo.geofenceLong!);
          _editRadius = geo.geofenceRadius;
        });
      } else {
        // Default to device's current location
        setState(() {
          _editCenter = LatLng(loc.latitude, loc.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseLocationService, GeofenceService>(
      builder: (context, locService, geoService, _) {
        final devicePos = LatLng(locService.latitude, locService.longitude);
        final center = _editCenter ?? devicePos;

        return Scaffold(
          backgroundColor: AppColors.backgroundPeach,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundPeach,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.primaryMaroon,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Set Geofence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
            centerTitle: true,
            actions: [
              if (geoService.isGeofenceSet)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.dangerRed,
                  tooltip: 'Clear Geofence',
                  onPressed: () => _clearGeofence(geoService),
                ),
            ],
          ),
          body: Column(
            children: [
              // Map
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 15.0,
                          onMapReady: () => _mapReady = true,
                          onTap: (tapPos, latLng) {
                            setState(() => _editCenter = latLng);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.gnb.mylock_candy',
                          ),
                          // Geofence circle
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (ctx, child) {
                              return CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: center,
                                    radius: _editRadius,
                                    color: AppColors.primaryMaroon
                                        .withValues(alpha: 0.08 + _pulseAnim.value * 0.04),
                                    borderColor: AppColors.primaryMaroon
                                        .withValues(alpha: 0.35),
                                    borderStrokeWidth: 2.0,
                                    useRadiusInMeter: true,
                                  ),
                                ],
                              );
                            },
                          ),
                          // Markers: device + geofence center
                          MarkerLayer(
                            markers: [
                              // Device marker
                              Marker(
                                point: devicePos,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.greenOnline,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.greenOnline
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.luggage,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                              // Geofence center marker (draggable visually via tap)
                              Marker(
                                point: center,
                                width: 52,
                                height: 62,
                                child: _buildGeofenceCenterMarker(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Instruction badge
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.touch_app_rounded,
                                color: AppColors.primaryMaroon, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap on the map to set geofence center',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Re-center button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (_mapReady) {
                              _mapController.move(devicePos, 15.0);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.my_location,
                                color: AppColors.primaryMaroon, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom controls
              _buildBottomControls(geoService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeofenceCenterMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE040FB), AppColors.primaryMaroon],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMaroon.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.shield_outlined,
              color: Colors.white, size: 22),
        ),
        CustomPaint(
          size: const Size(14, 10),
          painter: _TrianglePainter(color: AppColors.primaryMaroon),
        ),
      ],
    );
  }

  Widget _buildBottomControls(GeofenceService geoService) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radius display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPeach,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.radar_rounded,
                          color: AppColors.primaryMaroon, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Fence Radius',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryMaroon.withValues(alpha: 0.1),
                        AppColors.accentRose.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _editRadius >= 1000
                        ? '${(_editRadius / 1000).toStringAsFixed(1)} km'
                        : '${_editRadius.toStringAsFixed(0)} m',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Radius slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primaryMaroon,
                inactiveTrackColor: AppColors.ringGrey,
                thumbColor: AppColors.primaryMaroon,
                overlayColor: AppColors.primaryMaroon.withValues(alpha: 0.15),
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _editRadius,
                min: 100,
                max: 5000,
                divisions: 49,
                onChanged: (v) => setState(() => _editRadius = v),
              ),
            ),

            // Min / Max labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('100 m',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textLight)),
                  Text('5 km',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Coordinates info
            if (_editCenter != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPeach.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.ringGrey.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pin_drop_outlined,
                        size: 16, color: AppColors.primaryMaroon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_editCenter!.latitude.toStringAsFixed(6)}°, ${_editCenter!.longitude.toStringAsFixed(6)}°',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _editCenter == null
                    ? null
                    : () => _saveGeofence(geoService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryMaroon.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Activate Geofence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveGeofence(GeofenceService service) async {
    if (_editCenter == null) return;
    await service.setGeofence(
      _editCenter!.latitude,
      _editCenter!.longitude,
      _editRadius,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Geofence activated successfully'),
            ],
          ),
          backgroundColor: AppColors.greenOnline,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _clearGeofence(GeofenceService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Geofence'),
        content: const Text(
            'Are you sure you want to remove the geofence? You will no longer receive alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear',
                style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.clearGeofence();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Geofence removed'),
              ],
            ),
            backgroundColor: AppColors.textMedium,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
