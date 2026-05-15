import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/firebase_location_service.dart';
import '../theme/app_theme.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  LatLng? _previousPosition;

  @override
  void initState() {
    super.initState();
  }

  void _onCoordinatesChanged(FirebaseLocationService service) {
    final newPos = LatLng(service.latitude, service.longitude);
    if (_mapReady && _previousPosition != null && _previousPosition != newPos) {
      _mapController.move(newPos, 16.0);
      // Show notification snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Location updated: ${newPos.latitude.toStringAsFixed(4)}°, '
                  '${newPos.longitude.toStringAsFixed(4)}°',
                ),
              ],
            ),
            backgroundColor: AppColors.primaryMaroon,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
    return Consumer<FirebaseLocationService>(
      builder: (context, locationService, child) {
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: FlutterMap(
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
                    MarkerLayer(
                      markers: [
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

  Widget _buildLocationCard(
      FirebaseLocationService service, LatLng pos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.luggage,
                  color: AppColors.primaryMaroon,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Last seen
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.orangeStatus,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Last seen ${service.lastSeenText}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          Divider(color: AppColors.ringGrey, height: 1),
          const SizedBox(height: 14),

          // Coordinates
          Row(
            children: [
              Icon(Icons.my_location, size: 18, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text(
                'Lat ${pos.latitude.toStringAsFixed(4)}° N, '
                'Long ${pos.longitude.toStringAsFixed(4)}° E',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
