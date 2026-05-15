import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1;
  static const int _totalSteps = 4;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Title
          Text(
            'Fingerprint Setup',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Step $_currentStep of $_totalSteps',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Progress bar
          _buildProgressBar(),
          const SizedBox(height: 40),

          // Fingerprint card
          _buildFingerprintCard(),
          const SizedBox(height: 32),

          // Instructions
          const Text(
            'Place your finger on the\nlock sensor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Lift and rest your finger repeatedly to capture all angles securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Coming Soon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orangeStatus.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⚡ Hardware Feature — Coming Soon',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.orangeStatus,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Cancel Button
          OutlinedButton(
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              side: BorderSide(color: AppColors.primaryMaroon.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Cancel Setup',
              style: TextStyle(
                color: AppColors.primaryMaroon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isCompleted = index < _currentStep;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primaryMaroon : AppColors.ringGrey,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFingerprintCard() {
    return GestureDetector(
      onTap: () {
        if (_currentStep < _totalSteps) {
          setState(() => _currentStep++);
        } else {
          setState(() => _currentStep = 1);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryMaroon.withValues(alpha: 0.1),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.ringGrey,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMaroon.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.fingerprint,
                  size: 120,
                  color: AppColors.primaryMaroon,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
