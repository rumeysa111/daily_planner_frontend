import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  final Dio dio =
      Dio(BaseOptions(baseUrl: "http://192.168.0.105:3000/api/auth"));

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await dio
          .post('/login', data: {"email": email, "password": password});
      print(
          "Login API Response: ${response.data}"); // 📌 API'den gelen yanıtı konsola yazdır

      if (response.statusCode == 200) {
        final user = UserModel.fromMap(response.data);
        print(
            "✅ Backend'den Gelen Kullanıcı ID: ${user.id}"); // ✅ `userId`'yi kontrol edelim

        return user;
      }
    } catch (e) {
      print("Login error $e");
    }
    return null;
  }

  Future<bool> register(
      String name, String surname, String email, String password) async {
    try {
      final body = {
        "username": "$name $surname",
        "email": email,
        "password": password
      };

      print(
          "📢 Flutter Register API İsteği: $body"); // 🔍 İstek öncesinde veriyi logla

      final response = await dio.post('/register', data: body);

      print(
          "✅ Register API Yanıtı: ${response.data}"); // 🔍 Backend’den gelen yanıtı logla

      if (response.statusCode == 201) {
        final userId = response.data["userId"];
        final categories = response.data["categories"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        await prefs.setString("categories", categories.toString());

        return true; // ✅ Başarılı kayıt döndür
      }
    } catch (e) {
      print("❌ Register error: $e");
    }
    return false; // ❌ Kayıt başarısızsa false döndür
  }

  // 📌 Token ile kullanıcı bilgilerini çekme fonksiyonu (Eksik olan metod!)
  Future<UserModel?> getUser(String token) async {
    try {
      final response = await dio.get('/user',
          options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data);
      }
    } catch (e) {
      print("Get user error: $e");
    }
    return null;
  }

  Future<UserModel?> updateProfile(
      String token, String name, String email) async {
    try {
      final response = await dio.put(
        '/profile',
        data: {
          "name": name,
          "email": email,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data);
      }
    } catch (e) {
      print("Update profile error: $e");
    }
    return null;
  }

  Future<bool> changePassword(
      String token, String currentPassword, String newPassword) async {
    try {
      final response = await dio.post(
        '/change-password',
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }
}
