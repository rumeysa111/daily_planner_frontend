import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';

class CategoryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.0.105:3000/api/categories"));

  /// **✅ Kullanıcının kategorilerini getir**
  Future<List<CategoryModel>> fetchCategories(String userId) async {
    try {
      print("📢 Kullanıcı Kategorileri Getiriliyor: $userId"); // ✅ Debug
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await _dio.get(
        '/$userId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        print("✅ Backend'den Gelen Kategoriler: ${response.data}"); // ✅ Backend'den gelen veriyi yazdır

        List<CategoryModel> categories = (response.data as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        return categories;
      } else {
        throw Exception("Kategorileri getirirken hata oluştu!");
      }
    } catch (e) {
      print("🚨 Kategori çekme hatası: $e");
      return [];
    }
  }

  /// **✅ Yeni kategori ekle**
  Future<bool> addCategory(CategoryModel category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await _dio.post(
        '/',
        data: category.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}), // JWT Token ekleme
      );

      return response.statusCode == 201;
    } catch (e) {
      print("🚨 Kategori ekleme hatası: $e");
      return false;
    }
  }

  /// **✅ Kategori güncelle**
  Future<bool> updateCategory(String categoryId, CategoryModel category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await _dio.put(
        '/$categoryId',
        data: category.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Kategori güncelleme hatası: $e");
      return false;
    }
  }

  /// **✅ Kategori sil**
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await _dio.delete(
        '/$categoryId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Kategori silme hatası: $e");
      return false;
    }
  }
}
