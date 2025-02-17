import 'package:dio/dio.dart';
import 'package:mytodo_app/constans/api_constans.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';

class CategoryService {
   final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstans.BASE_URL + "/categories"));

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
        print(
            "✅ Backend'den Gelen Kategoriler: ${response.data}"); // ✅ Backend'den gelen veriyi yazdır

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
      print("📌 Kategori ekleme isteği başlatılıyor..."); // Debug log
      print(
          "📌 Kategori verisi: ${category.toJson()}"); // Gönderilen veriyi kontrol et

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? userId = prefs.getString("userId");

      if (token == null || userId == null) {
        print("🚨 Token veya UserId bulunamadı!");
        return false;
      }

      // userId'yi kategori verisine ekle
      final categoryData = {
        ...category.toJson(),
        "userId": userId,
      };

      print("📌 Backend'e gönderilen data: $categoryData"); // Debug log

      final response = await _dio.post(
        '/',
        data: categoryData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          validateStatus: (status) => status! < 500, // HTTP durumunu kontrol et
        ),
      );

      print("📌 Backend response: ${response.data}"); // Debug log
      print(
          "📌 Status code: ${response.statusCode}"); // Status code'u kontrol et

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Kategori başarıyla eklendi!");
        return true;
      } else {
        print("🚨 Kategori eklenemedi! Status: ${response.statusCode}");
        print("🚨 Hata mesajı: ${response.data}");
        return false;
      }
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
