// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mytodo_app/constans/api_constans.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  final Dio dio =
      Dio(BaseOptions(baseUrl: ApiConstans.BASE_URL));

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await dio
          .post('/auth/login', data: {"email": email, "password": password});
      print(
          "Login API Response: ${response.data}"); //  API'den gelen yanıtı konsola yazdır

      if (response.statusCode == 200) {
        final user = UserModel.fromMap(response.data);
        print(
            " Backend'den Gelen Kullanıcı ID: ${user.id}"); 

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
          " Flutter Register API İsteği: $body"); //  İstek öncesinde veriyi logla

      final response = await dio.post('/auth/register', data: body);

      print(
          " Register API Yanıtı: ${response.data}"); //  Backend’den gelen yanıtı logla

      if (response.statusCode == 201) {
        final userId = response.data["userId"];
        final categories = response.data["categories"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        await prefs.setString("categories", categories.toString());

        return true; //  Başarılı kayıt döndür
      }
    } catch (e) {
      print(" Register error: $e");
    }
    return false; //  Kayıt başarısızsa false döndür
  }

  //  Token ile kullanıcı bilgilerini çekme fonksiyonu 
  Future<UserModel?> getUser(String token) async {
    try {
      final response = await dio.get('/auth/user',
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
        '/auth/profile',
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
      if (kDebugMode) {
        print("Update profile error: $e");
      }
    }
    return null;
  }

  Future<bool> changePassword(
      String token, String currentPassword, String newPassword) async {
    try {
      final response = await dio.post(
        '/auth/change-password',
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