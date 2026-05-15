import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LockRing extends StatelessWidget {
  final bool isLocked;
  final double size;

  const LockRing({
    super.key,
    required this.isLocked,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LockRingPainter(isLocked: isLocked),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                size: 48,
                color: AppColors.primaryMaroon,
              ),
              const SizedBox(height: 8),
              Text(
                isLocked ? 'LOCKED' : 'UNLOCKED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.primaryMaroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockRingPainter extends CustomPainter {
  final bool isLocked;

  _LockRingPainter({required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    // Background ring (grey)
    final bgPaint = Paint()
      ..color = AppColors.ringGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc (maroon)
    final fgPaint = Paint()
      ..color = AppColors.primaryMaroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw ~270 degree arc starting from top-right
    const startAngle = -pi / 2 - 0.15; // slight offset from top
    const sweepAngle = 4.7; // ~270 degrees in radians

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LockRingPainter oldDelegate) {
    return oldDelegate.isLocked != isLocked;
  }
}
