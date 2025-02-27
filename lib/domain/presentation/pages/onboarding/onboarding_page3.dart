// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({Key? key}) : super(key: key); // const constructor ekleyelim

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context); // Daha performanslı yöntem
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
                  offset: const Offset(0, 10), // const ekledik
                ),
              ],
            ),
            padding: const EdgeInsets.all(24), // const ekledik
            child: Image.asset(
              'assets/images/onboarding3.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20), // const ekledik
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // const ekledik
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10), // const ekledik
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
                const SizedBox(height: 16), // const ekledik
                Text(
                  "Hatırlatıcılar sayesinde hiçbir görevi unutma ve zamanında tamamla.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24), // const ekledik
                Container(
                  padding: const EdgeInsets.all(16), // const ekledik
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
                      const SizedBox(width: 12), // const ekledik
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Akıllı Hatırlatıcılar",
                            style: const TextStyle( // const ekledik
                              fontWeight: FontWeight.bold,
                            ).copyWith(
                              color: AppColors.primary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          const SizedBox(height: 4), // const ekledik
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
