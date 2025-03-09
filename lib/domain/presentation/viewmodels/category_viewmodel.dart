// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/data/repositories/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/category_model.dart';

class CategoryViewModel extends StateNotifier<List<CategoryModel>> {
  final CategoryService _categoryService;
  String selectedCategoryId = ""; // Varsayılan olarak seçili kategori yok

  CategoryViewModel(this._categoryService) : super([]) {
    fetchCategories();
  }

  ///  Kullanıcının kategorilerini çek
  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      if (kDebugMode) {
        print(" Kullanıcı giriş yapmamış! Kategoriler yüklenemedi.");
      }
      return;
    }
    print(" Kullanıcının kategorileri yükleniyor: $userId"); // ✅ Debug

    try {
      final categories = await _categoryService.fetchCategories(userId);
      state = categories; // ✅ Backend’den gelen kategorileri UI’a aktar
      if (kDebugMode) {
        print("✅ ${categories.length} kategori yüklendi.");
      }
    } catch (e) {
      print(" Kategorileri çekerken hata oluştu: $e");
    }
  }

  void reloadCategories() {
    fetchCategories(); // ✅ Kullanıcı değişirse yeniden yükle
  }

  ///  Yeni kategori ekle
  Future<bool> addCategory(CategoryModel category) async {
    try {
      // SharedPreferences'dan userId'yi al
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("🚨 Kullanıcı ID'si bulunamadı!");
        return false;
      }

      // Kategori nesnesini userId ile güncelle
      final categoryWithUserId = CategoryModel(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        userId: userId, // Kullanıcı ID'sini ekle
      );

      // Güncellenmiş kategoriyi backende gönder
      bool success = await _categoryService.addCategory(categoryWithUserId);
      if (success) {
        await fetchCategories(); // Tüm kategorileri yeniden yükle
        return true;
      }
      return false;
    } catch (e) {
      print(" Kategori ekleme hatası: $e");
      return false;
    }
  }

  ///  Kategori güncelle
  Future<bool> updateCategory(
      String categoryId, CategoryModel updatedCategory) async {
    try {
      bool success =
          await _categoryService.updateCategory(categoryId, updatedCategory);
      if (success) {
        await fetchCategories(); // Tüm kategorileri yeniden yükle
        return true;
      }
      return false;
    } catch (e) {
      print(" Kategori güncelleme hatası: $e");
      return false;
    }
  }

  ///  Kategori sil
  Future<void> deleteCategory(String categoryId) async {
    bool success = await _categoryService.deleteCategory(categoryId);
    if (success) {
      state = state.where((cat) => cat.id != categoryId).toList();
    }
  }

  ///  Kullanıcı çıkış yaptığında kategorileri temizle**
  void clearCategories() {
    state = [];
  }

  /// Seçili kategoriyi ayarla
  void setCategory(String categoryId) {
    selectedCategoryId = categoryId;
    state = [...state]; // UI güncellemek için state değiştirme
  }
}

