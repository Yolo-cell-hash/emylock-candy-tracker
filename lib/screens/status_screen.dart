import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/lock_ring.dart';
import '../widgets/stat_card.dart';
import '../widgets/ble_status_chip.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isLocked = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // BLE Status Chip
          const BleStatusChip(isConnected: false),
          const SizedBox(height: 12),

          // Dashboard Title
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),

          // Lock Ring
          LockRing(isLocked: _isLocked, size: 240),
          const SizedBox(height: 36),

          // Hold to Unlock / Lock Button
          _buildUnlockButton(),
          const SizedBox(height: 12),

          // Coming Soon note
          Text(
            'BLE hardware integration coming soon',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),

          // Power and Signal Cards
          Row(
            children: const [
              StatCard(
                icon: Icons.battery_5_bar_rounded,
                label: 'Power',
                value: '85%',
              ),
              SizedBox(width: 12),
              StatCard(
                icon: Icons.signal_cellular_alt_rounded,
                label: 'Signal',
                value: 'Strong',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUnlockButton() {
    return GestureDetector(
      onLongPress: () {
        setState(() => _isLocked = !_isLocked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lightMaroon, AppColors.primaryMaroon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMaroon.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              _isLocked ? 'Hold to Unlock' : 'Hold to Lock',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bluetooth, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'Secure BLE Link',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
