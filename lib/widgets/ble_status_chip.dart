import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BleStatusChip extends StatelessWidget {
  final bool isConnected;

  const BleStatusChip({super.key, this.isConnected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.greenOnline.withValues(alpha: 0.1)
            : AppColors.textLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? AppColors.greenOnline.withValues(alpha: 0.3)
              : AppColors.textLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.greenOnline : AppColors.textLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'BLE Connected' : 'BLE Disconnected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isConnected ? AppColors.greenOnline : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
