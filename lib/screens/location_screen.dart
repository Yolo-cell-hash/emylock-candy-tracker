import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/firebase_location_service.dart';
import '../services/geofence_service.dart';
import '../theme/app_theme.dart';
import 'geofence_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  LatLng? _previousPosition;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onCoordinatesChanged(FirebaseLocationService service) {
    final newPos = LatLng(service.latitude, service.longitude);
    if (_mapReady && _previousPosition != null && _previousPosition != newPos) {
      _mapController.move(newPos, 16.0);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location updated: ${newPos.latitude.toStringAsFixed(5)}°, '
                    '${newPos.longitude.toStringAsFixed(5)}°',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryMaroon,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    _previousPosition = newPos;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseLocationService, GeofenceService>(
      builder: (context, locationService, geoService, child) {
        final pos = LatLng(locationService.latitude, locationService.longitude);

        // Trigger side-effects after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onCoordinatesChanged(locationService);
        });

        return Column(
          children: [
            // Map area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: pos,
                      initialZoom: 16.0,
                      onMapReady: () {
                        _mapReady = true;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.gnb.mylock_candy',
                      ),
                      // Geofence circle overlay (if set)
                      if (geoService.isGeofenceSet &&
                          geoService.geofenceLat != null &&
                          geoService.geofenceLong != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(geoService.geofenceLat!,
                                  geoService.geofenceLong!),
                              radius: geoService.geofenceRadius,
                              color: (geoService.isInsideGeofence
                                      ? AppColors.greenOnline
                                      : AppColors.dangerRed)
                                  .withValues(alpha: 0.10),
                              borderColor: (geoService.isInsideGeofence
                                      ? AppColors.greenOnline
                                      : AppColors.dangerRed)
                                  .withValues(alpha: 0.40),
                              borderStrokeWidth: 2.0,
                              useRadiusInMeter: true,
                            ),
                          ],
                        ),
                      // Pulsing accuracy ring
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: pos,
                            radius: locationService.accuracy > 0
                                ? locationService.accuracy.clamp(20, 120)
                                : 40,
                            color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                            borderColor:
                                AppColors.primaryMaroon.withValues(alpha: 0.20),
                            borderStrokeWidth: 1.5,
                            useRadiusInMeter: true,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          // Geofence center marker
                          if (geoService.isGeofenceSet &&
                              geoService.geofenceLat != null &&
                              geoService.geofenceLong != null)
                            Marker(
                              point: LatLng(geoService.geofenceLat!,
                                  geoService.geofenceLong!),
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMaroon
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryMaroon,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.shield_outlined,
                                    color: AppColors.primaryMaroon, size: 16),
                              ),
                            ),
                          // Device marker
                          Marker(
                            point: pos,
                            width: 52,
                            height: 62,
                            child: _buildMapMarker(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Live indicator badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: locationService.hasReceivedUpdate
                                      ? AppColors.greenOnline
                                      : AppColors.orangeStatus,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (locationService.hasReceivedUpdate
                                              ? AppColors.greenOnline
                                              : AppColors.orangeStatus)
                                          .withValues(
                                              alpha: _pulseAnimation.value),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                locationService.hasReceivedUpdate
                                    ? 'LIVE'
                                    : 'CONNECTING',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: locationService.hasReceivedUpdate
                                      ? AppColors.greenOnline
                                      : AppColors.orangeStatus,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Geofence status badge (if geofence is set)
                  if (geoService.isGeofenceSet)
                    Positioned(
                      top: 12,
                      left: 110,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              geoService.isInsideGeofence
                                  ? Icons.shield_rounded
                                  : Icons.warning_rounded,
                              size: 14,
                              color: geoService.isInsideGeofence
                                  ? AppColors.greenOnline
                                  : AppColors.dangerRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              geoService.isInsideGeofence
                                  ? 'SAFE'
                                  : 'OUTSIDE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: geoService.isInsideGeofence
                                    ? AppColors.greenOnline
                                    : AppColors.dangerRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Re-center button + Set Geofence button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        Material(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (_mapReady) {
                                _mapController.move(pos, 16.0);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.my_location,
                                color: AppColors.primaryMaroon,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GeofenceScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                geoService.isGeofenceSet
                                    ? Icons.shield_rounded
                                    : Icons.shield_outlined,
                                color: geoService.isGeofenceSet
                                    ? AppColors.greenOnline
                                    : AppColors.primaryMaroon,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location info card
            _buildLocationCard(locationService, pos),
          ],
        );
      },
    );
  }

  Widget _buildMapMarker() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.lightMaroon,
                AppColors.primaryMaroon,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMaroon.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.luggage,
            color: Colors.white,
            size: 24,
          ),
        ),
        // Pointer triangle
        CustomPaint(
          size: const Size(14, 10),
          painter: _TrianglePainter(color: AppColors.primaryMaroon),
        ),
      ],
    );
  }

  Widget _buildLocationCard(FirebaseLocationService service, LatLng pos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with live status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Live Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: service.hasReceivedUpdate
                              ? AppColors.greenOnline
                              : AppColors.orangeStatus,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (service.hasReceivedUpdate
                                      ? AppColors.greenOnline
                                      : AppColors.orangeStatus)
                                  .withValues(alpha: _pulseAnimation.value),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  service.lastSeenText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Data grid — 2×2 layout for lat, lng, alt, timestamp
          Row(
            children: [
              Expanded(
                child: _buildDataTile(
                  icon: Icons.north,
                  label: 'Latitude',
                  value: pos.latitude.toStringAsFixed(7),
                  suffix: '°',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDataTile(
                  icon: Icons.east,
                  label: 'Longitude',
                  value: pos.longitude.toStringAsFixed(7),
                  suffix: '°',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDataTile(
                  icon: Icons.height,
                  label: 'Altitude',
                  value: '14.0', // TODO: restore to service.altitude.toStringAsFixed(1)
                  suffix: ' m',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDataTile(
                  icon: Icons.access_time_filled,
                  label: 'Last Fetch',
                  value: service.polledAtFormatted,
                  suffix: '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildDataTile({
    required IconData icon,
    required String label,
    required String value,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundPeach.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.ringGrey.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryMaroon),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value$suffix',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
