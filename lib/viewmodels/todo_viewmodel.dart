import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/todo_service.dart';

class TodoViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  String? selectedCategory = "Tümü"; // 📌 Varsayılan olarak tüm görevleri getir
  List<TodoModel> allTodos = []; // 📌 Backend'den gelen tüm görevler

  TodoViewModel(this._todoService) : super([]) {
    fetchTodos();
  }
  /// 📌 Token'ı SharedPreferences'tan al
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("token");
    } catch (e) {
      print("🚨 Token alınırken hata oluştu: $e");
      return null;
    }
  }

  Future<void> fetchTodos({String? category}) async {
    final token = await _getToken();
    if (token == null) {
      print("kullanıcı giriş yapmamış token bulunamadı");

      state = [];
      return;
    }
    try {
      final todos = await _todoService.fetchTodos(token,category: category);
      allTodos = todos; // 📌 Tüm görevleri kaydet
      filterTodos(); // 📌 Seçilen kategoriye göre filtreleme yap
      print("✅ Görevler güncellendi: ${state.length} görev var.");
    } catch (e) {
      print("🚨 Görevleri çekerken hata oluştu: $e");
    }
  }
  /// 📌 Frontend tarafında kategoriye göre filtreleme yap
  void filterTodos() {
    if (selectedCategory == "Tümü") {
      state = allTodos;
    } else {
      state = allTodos.where((todo) => todo.category == selectedCategory).toList();
    }
  }


  void setCategory(String category) async {
    selectedCategory = category;
    filterTodos(); // 📌 Yeni kategoriye göre filtreleme yap

  }


  Future<void> addTodo(TodoModel todo) async {
    final token = await _getToken();

    if (token == null) {
      print("token bulunamadı");
      return;
    }
    print("📌 Backend'e görev ekleniyor: ${todo.toJson()}");

    bool success = await _todoService.addTodo(token, todo);
    if (success) {
      print("✅ Görev başarıyla eklendi, liste güncelleniyor...");
      fetchTodos();
    } else {
      print("🚨 Görev ekleme başarısız!");
    }
  }

/*  Future<void> updateTodo(String id, TodoModel todo) async {
    final token=await _getToken();
    if(token==null) return;
    bool success=await _todoService.updateTodo(token);
    if(success) fetchTodos();
  }*/

  Future<void> deleteTodo(String id) async {
    final token = await _getToken();
    if (token == null) return;
    bool success = await _todoService.deleteTodo(token, id);
    if (success) fetchTodos();
  }
}

final todoProvider =
    StateNotifierProvider<TodoViewModel, List<TodoModel>>((ref) {
  return TodoViewModel(TodoService());
});
