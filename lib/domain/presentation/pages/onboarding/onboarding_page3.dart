import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class OnboardingPage3 extends StatelessWidget {
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
              'assets/images/onboarding3.png',
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
                  "Önemli İşleri Kaçırma!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Hatırlatıcılar sayesinde hiçbir görevi unutma ve zamanında tamamla.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.primary,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Akıllı Hatırlatıcılar",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Zamanında bildirim al",
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.8),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
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
