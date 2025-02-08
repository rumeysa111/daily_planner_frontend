import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/models/category_model.dart';
import 'package:mytodo_app/services/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryViewModel extends StateNotifier<List<CategoryModel>> {
  final CategoryService _categoryService;
  String selectedCategoryId = ""; // Varsayılan olarak seçili kategori yok

  CategoryViewModel(this._categoryService) : super([]) {
    fetchCategories();
  }

  /// ✅ Kullanıcının kategorilerini çek
  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("🚨 Kullanıcı giriş yapmamış! Kategoriler yüklenemedi.");
      return;
    }
    print("📢 Kullanıcının kategorileri yükleniyor: $userId"); // ✅ Debug

    try {
      final categories = await _categoryService.fetchCategories(userId);
      state = categories; // ✅ Backend’den gelen kategorileri UI’a aktar
      print("✅ ${categories.length} kategori yüklendi.");
    } catch (e) {
      print("🚨 Kategorileri çekerken hata oluştu: $e");
    }
  }
  void reloadCategories() {
    fetchCategories(); // ✅ Kullanıcı değişirse yeniden yükle
  }

  /// ✅ Yeni kategori ekle
  Future<void> addCategory(CategoryModel category) async {
    bool success = await _categoryService.addCategory(category);
    if (success) {
      state = [...state, category]; // ✅ Yeni kategoriyi listeye ekle
    }
  }

  /// ✅ Kategori güncelle
  Future<void> updateCategory(String categoryId, CategoryModel updatedCategory) async {
    bool success = await _categoryService.updateCategory(categoryId, updatedCategory);
    if (success) {
      state = state.map((cat) => cat.id == categoryId ? updatedCategory : cat).toList();
    }
  }

  /// ✅ Kategori sil
  Future<void> deleteCategory(String categoryId) async {
    bool success = await _categoryService.deleteCategory(categoryId);
    if (success) {
      state = state.where((cat) => cat.id != categoryId).toList();
    }
  }
  /// **📌 Kullanıcı çıkış yaptığında kategorileri temizle**
  void clearCategories() {
    state = [];
  }


  /// ✅ Seçili kategoriyi ayarla
  void setCategory(String categoryId) {
    selectedCategoryId = categoryId;
    state = [...state]; // UI güncellemek için state değiştirme
  }
}

/// 📌 Riverpod Provider
final categoryProvider = StateNotifierProvider<CategoryViewModel, List<CategoryModel>>((ref) {
  return CategoryViewModel(CategoryService());
});
