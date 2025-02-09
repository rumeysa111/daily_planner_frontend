import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref
        .watch(authProvider); // Kullanıcının giriş yapıp yapmadığını takip et

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          // 📌 Kaydırılabilir ekran (klavye açılınca bozulmaz)
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    screenWidth * 0.08), // 📌 Cihaz genişliğine bağlı padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: screenHeight *
                        0.12), // 📌 Ekran yüksekliğine göre yukarı boşluk

                // 📌 "Hoşgeldiniz" Yazısı
                Text(
                  "Hoşgeldiniz",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08, // 📌 Dinamik font boyutu
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: screenHeight * 0.04), // 📌 Boşluk

                // 📌 "Giriş Yap" Başlığı
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // 📌 Dinamik font boyutu
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03), // 📌 Boşluk

                // 📌 Form Alanı (TextField'ler)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      hintText: "E-posta adresiniz",
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    CustomTextField(
                      hintText: "Şifreniz",
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      isPassword: true,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // 📌 Şifremi Unuttum Linki
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text("Şifremi Unuttum",
                            style: TextStyle(color: AppColors.primary)),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // 📌 Giriş Butonu
                    CustomButton(
                      text: "Giriş Yap",
                      onPressed: () async {
                        final success = await ref
                            .read(authProvider.notifier)
                            .login(
                                emailController.text, passwordController.text);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Başarılı Giriş!")));
                          Navigator.pushNamed(context, AppRoutes.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Giriş Başarısız!")));
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(
                    height:
                        screenHeight * 0.02), // 📌 Formun altına boşluk ekledik

                // 📌 Kayıt Ol Linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hesabınız yok mu?",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text("Kayıt Ol",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03), // 📌 Alt boşluk
              ],
            ),
          ),
        ),
      ),
    );
  }
}
