import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({Key? key}) : super(key: key); // const constructor eklendi

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
  width: double.infinity, // Sabit genişlik
  decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  padding: const EdgeInsets.all(24),
  child: Image.asset(
    'assets/images/onboarding44.png',
    fit: BoxFit.contain,
    cacheWidth: (size.width * 0.8).toInt(), // Resim önbellekleme
    cacheHeight: (size.height * 0.35).toInt(),
  ),
),
          const SizedBox(height: 20), // Gereksiz MediaQuery kullanımını azalttık
          Padding( // Gereksiz Container kullanımı kaldırıldı
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // const eklendi
            child: DecoratedBox( // Daha iyi performans için `Container` yerine kullanıldı
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10), // const eklendi
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24), // `Container` yerine `Padding` ekledik
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
                    const SizedBox(height: 16),
                    Text(
                      "Sesli komutlarla görevlerini yönet, AI asistanından yardım al ve işlerini daha akıllı bir şekilde organize et",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: isSmallScreen ? 14 : 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureItem(
                          key: const ValueKey("voice-command"), // Gereksiz rebuild'leri önler
                          icon: Icons.mic,
                          label: "Sesli Komut",
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(width: 16), // `const` eklendi
                        _buildFeatureItem(
                          key: const ValueKey("ai-chat"), // Gereksiz rebuild'leri önler
                          icon: Icons.chat_bubble_outline,
                          label: "AI Sohbet",
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    Key? key, // Key eklenerek gereksiz rebuild önlendi
    required IconData icon,
    required String label,
    required bool isSmallScreen,
  }) {
    return Container(
      key: key, // Key kullanımı ile gereksiz build çağrılarının önüne geçildi
      padding: const EdgeInsets.all(16), // const eklendi
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
          const SizedBox(height: 8), // const eklendi
          Text(
            label,
            style: const TextStyle( // const eklendi
              fontWeight: FontWeight.w600,
            ).copyWith(
              color: AppColors.primary,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
