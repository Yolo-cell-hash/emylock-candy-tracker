import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Title
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your luggage preferences and firmware.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),

          // Settings list
          _buildSettingsTile(
            icon: Icons.phone_android,
            title: 'Device Name',
            subtitle: 'MyLock Candy - Jet Black',
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.bluetooth_searching,
            title: 'BLE Range Sensitivity',
            subtitle: 'Medium (Auto-Lock optimized)',
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.system_update_outlined,
            title: 'Firmware Update',
            subtitle: 'Update available (v2.1.4)',
            hasUpdate: true,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.support_agent,
            title: 'Support',
          ),
          const SizedBox(height: 32),

          // Factory Reset
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showResetDialog(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Factory Reset Luggage',
                style: TextStyle(
                  color: AppColors.dangerRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool hasUpdate = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryMaroon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUpdate
                          ? AppColors.orangeStatus
                          : AppColors.textLight,
                      fontWeight:
                          hasUpdate ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textLight,
            size: 22,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Factory Reset'),
        content: const Text(
          'This will reset your luggage to factory settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        ],
      ),
    );
  }
}
