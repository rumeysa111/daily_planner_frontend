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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08), // 📌 Üst boşluk azaltıldı

                // 📌 "Kayıt Ol" Başlığı
                Text(
                  "Kayıt Ol",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02), // 📌 Boşluk azaltıldı

                // 📌 "Hesap Oluştur" Başlığı
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // 📌 Form Alanı
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hintText: "Ad",
                            icon: Icons.person,
                            controller: nameController,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            hintText: "Soyad",
                            icon: Icons.person,
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

                    SizedBox(height: screenHeight * 0.02),

                    // 📌 Kayıt Ol Butonu
                    CustomButton(
                      text: "Kayıt Ol",
                      onPressed: () async {
                        if (passwordController.text != passwordControllerAgain.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Şifreler uyuşmuyor!"))
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
                            SnackBar(content: Text("Kayıt başarılı"))
                          );
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Kayıt başarısız!"))
                          );
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // 📌 Giriş Yap Linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hesabınız var mı?",
                      style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        "Giriş Yap",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
