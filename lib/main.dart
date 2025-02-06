import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📌 Riverpod'u ekledik!
import 'package:mytodo_app/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/auth/login_page.dart'; // 📌 Login sayfasını çağırıyoruz

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 📌 Flutter uygulaması başlatıldı

  //shared prefencsten token kontorl ediliyor
  final prefs=await SharedPreferences.getInstance();
  final String? token =prefs.getString("token");
  runApp(
    ProviderScope( // 📌 Riverpod için ProviderScope EKLENMELİ!
      child: MyApp(isLoggenIn: token!=null),//kullnaıcı giriş yapmış mı

    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggenIn;
  MyApp({required this.isLoggenIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      initialRoute: isLoggenIn ? AppRoutes.home: AppRoutes.onboarding,//uygulama ilk açıldıgında login sayfası gelicek
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
