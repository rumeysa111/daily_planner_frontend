import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class OnboardingPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.08,
        vertical: size.height * 0.04,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.35,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Image.asset(
              'assets/images/onboarding4.png', // AI asistan görseli
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: size.height * 0.05),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "AI Asistanınla Tanış",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Sesli komutlarla görevlerini yönet, AI asistanından yardım al ve işlerini daha akıllı bir şekilde organize et",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureItem(
                      icon: Icons.mic,
                      label: "Sesli Komut",
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(width: 16),
                    _buildFeatureItem(
                      icon: Icons.chat_bubble_outline,
                      label: "AI Sohbet",
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: isSmallScreen ? 24 : 28,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
