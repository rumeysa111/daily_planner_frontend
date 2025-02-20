import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class OnboardingPage1 extends StatelessWidget {
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
            ),
            padding: EdgeInsets.all(24),
            child: Image.asset(
              'assets/images/onboarding1.png',
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
                  "Hoş Geldiniz!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 28,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Tüm görevlerini, hatırlatıcılarını ve etkinliklerini tek bir yerden yönet.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "İpucu: Kaydır ve keşfet!",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}