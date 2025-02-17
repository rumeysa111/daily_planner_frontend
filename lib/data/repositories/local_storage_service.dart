import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveUserName(String name) async{
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString("username", name);
  }
  static Future<String> getUserName() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString("username") ?? "Kullanıcı";
  }
}