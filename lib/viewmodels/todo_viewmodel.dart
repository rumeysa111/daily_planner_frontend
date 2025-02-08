import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/todo_service.dart';

class TodoViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  DateTime selectedDate = DateTime.now();

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
      print("🚨 Kullanıcı giriş yapmamış, token bulunamadı");
      state = [];
      return;
    }
    try {
      final todos = await _todoService.fetchTodos(token, category: category);
      allTodos = todos;
      state = todos; // StateNotifier will automatically notify listeners
      print("✅ Görevler güncellendi: ${todos.length} görev var.");
    } catch (e) {
      print("🚨 Görevleri çekerken hata oluştu: $e");
      state = [];
    }
  }

  //seçili tarihe göre görevleri çek
  Future<void> fetchTodosByDate(DateTime date) async {
    final token = await _getToken();
    if (token == null) {
      state = [];
      return;
    }
    try {
      final todos = await _todoService.fetchTodosByDate(token, date);
      state = todos;
      selectedDate = date;
      print(
          "✅ ${date.toIso8601String()} tarihine ait ${state.length} görev var.");
    } catch (e) {
      print("seçili tarihe göre görevleri çekerken hata oluştu");
    }
  }

  /// 📌 Bugünün görevlerini getir
  List<TodoModel> get todayTasks {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    return state.where((task) {
      if (task.dueDate == null) return false;
      DateTime taskDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate == todayWithoutTime;
    }).toList();
  }

  //takvimde seçili tarihi güncelle ve yeni görevleri getir
  void setSelectedDate(DateTime date) {
    fetchTodosByDate(date);
  }

  /// 📌 Frontend tarafında kategoriye göre filtreleme yap
  void filterTodos() {
    if (selectedCategory == "Tümü") {
      state = [...allTodos];
    } else {
      state = [
        ...allTodos
            .where((todo) => todo.categoryId == selectedCategory)
            .toList()
      ];
    }
  }

  void setCategory(String category) async {
    selectedCategory = category;
    filterTodos(); // 📌 Yeni kategoriye göre filtreleme yap
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final token = await _getToken();
    if (token == null) return;

    // 📌 Önce UI'de değiştir
    state = List.from(state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }));

    // 📌 Backend'e gönder
    Future.delayed(Duration(milliseconds: 500), () async {
      final taskToUpdate = state.firstWhere((task) => task.id == taskId);
      await _todoService.updateTodo(token, taskId, taskToUpdate);
    });
  }

  Future<void> addTodo(TodoModel todo) async {
    final token = await _getToken();
    if (token == null) {
      print("token bulunamadı");
      return;
    }

    try {
      print("📌 Backend'e görev ekleniyor: ${todo.toJson()}");
      bool success = await _todoService.addTodo(token, todo);

      if (success) {
        print("✅ Görev başarıyla eklendi");
        // Backend'den güncel listeyi al
        await fetchTodos();

        // Eğer bir kategori seçiliyse, o kategoriye göre filtrele
        if (selectedCategory != "Tümü") {
          filterTodos();
        }
      } else {
        print("🚨 Görev ekleme başarısız!");
      }
    } catch (e) {
      print("🚨 Görev eklerken hata: $e");
    }
  }

  Future<void> deleteTodo(String id) async {
    final token = await _getToken();
    if (token == null) return;

    // 📌 UI'den hemen kaldır (Beklemeden)
    state = List.from(state.where((task) => task.id != id));

    // 📌 Backend'e bildir (Eğer hata olursa geri al)
    bool success = await _todoService.deleteTodo(token, id);
    if (!success) {
      print("🚨 Görev silme başarısız oldu, UI'yi geri alıyoruz!");
      fetchTodos(); // Hata olursa backend’den veriyi tekrar al
    }
  }
}

final todoProvider =
    StateNotifierProvider<TodoViewModel, List<TodoModel>>((ref) {
  return TodoViewModel(TodoService());
});
