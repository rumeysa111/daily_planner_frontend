import 'package:flutter/material.dart';
import 'package:mytodo_app/views/home/add_task_page.dart';
import 'package:mytodo_app/views/home/all_task_page.dart';
import 'package:mytodo_app/views/home/home_page.dart';
import 'package:mytodo_app/views/onboarding/onboarding_page1.dart';
import 'package:mytodo_app/views/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/home/navbar.dart';

class AppRoutes {
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  static const String onboarding = "/onboarding";
  static const String alltask = "/alltask";
  static const String addtask="/addtask";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case alltask:
        return MaterialPageRoute(builder: (_) => AllTasksPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());

      case home:
        return MaterialPageRoute(
            builder: (_) => _getHomePage()); // 📌 Navbar'a yönlendirdik!
      case addtask:
        return MaterialPageRoute(
            builder: (_) => AddTaskPage()); // 📌 Navbar'a yönlendirdik!
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("404 - Sayfa Bulunamadı")),
          ),
        );
    }
  }
  //token kontrolü ile yönlendirme yapan fonksiyon
static Widget _getHomePage(){
    return FutureBuilder<bool>(
    future: _isLoggedIn(),
  builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return Scaffold(body: Center(child: CircularProgressIndicator(),),);
      }else{
        return snapshot.data==true?Navbar():LoginPage();
      }
  });
}
//kullanıcı giriş yapmış mı kontrol eden fonksiyon
  // 📌 Kullanıcı giriş yapmış mı kontrol eden fonksiyon
  static Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }
}