import 'package:flutter/material.dart';
import 'package:mytodo_app/theme/colors.dart';

class OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // 📌 Tema rengini kullan
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/onboarding1.png', height: 250), // 📌 Onboarding için görsel
          SizedBox(height: 20),
          Text(
            "Görevlerini Kolayca Yönet",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 10),
          Text(
            "Kategorilere ayır, hatırlatıcılar ekle ve görevlerini zamanında tamamla",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
