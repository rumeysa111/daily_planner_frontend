// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dio/dio.dart';
import 'package:mytodo_app/constans/api_constans.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';

class CategoryService {
   final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstans.BASE_URL + "/categories"));

  /// Kullanıcının kategorilerini getir**
  Future<List<CategoryModel>> fetchCategories(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await _dio.get(
        '/$userId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        // ✅ Backend'den gelen veriyi yazdır

        List<CategoryModel> categories = (response.data as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        return categories;
      } else {
        throw Exception("Kategorileri getirirken hata oluştu!");
      }
    } catch (e) {
      return [];
    }
  }

  /// Yeni kategori ekle**
  Future<bool> addCategory(CategoryModel category) async {
    try {
      // Debug log
      // Gönderilen veriyi kontrol et

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? userId = prefs.getString("userId");

      if (token == null || userId == null) {
        return false;
      }

      // userId'yi kategori verisine ekle
      final categoryData = {
        ...category.toJson(),
        "userId": userId,
      };

      // Debug log

      final response = await _dio.post(
        '/',
        data: categoryData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          validateStatus: (status) => status! < 500, // HTTP durumunu kontrol et
        ),
      );

      // Debug log
      // Status code'u kontrol et

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  ///  Kategori güncelle**
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
      return false;
    }
  }

  /// Kategori sil**
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
      return false;
    }
  }
}
