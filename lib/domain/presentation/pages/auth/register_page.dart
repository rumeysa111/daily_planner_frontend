import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/core/theme/colors.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';


class RegisterPage extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerAgain = TextEditingController();

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    backgroundColor: theme.colorScheme.background,
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.08),

              // Kayıt Ol Başlığı
              Text(
                "Kayıt Ol",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Hesap Oluştur Başlığı
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hesap Oluştur",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Form Alanı
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: "Ad",
                          icon: Icons.person_outline,
                          controller: nameController,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          hintText: "Soyad",
                          icon: Icons.person_outline,
                          controller: surnameController,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  CustomTextField(
                    hintText: "E-posta adresiniz",
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  CustomTextField(
                    hintText: "Şifreniz",
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    isPassword: true,
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  CustomTextField(
                    hintText: "Şifrenizi tekrar giriniz",
                    icon: Icons.lock_outline,
                    controller: passwordControllerAgain,
                    isPassword: true,
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Kayıt Ol Butonu
                  CustomButton(
                    text: "Kayıt Ol",
                    onPressed: () async {
                      if (passwordController.text != passwordControllerAgain.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Şifreler uyuşmuyor!"),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final success = await ref.read(authProvider.notifier).register(
                        nameController.text,
                        surnameController.text,
                        emailController.text,
                        passwordController.text
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Kayıt başarılı"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Kayıt başarısız!"),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Giriş Yap Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hesabınız var mı?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    ),
  );
}
}
