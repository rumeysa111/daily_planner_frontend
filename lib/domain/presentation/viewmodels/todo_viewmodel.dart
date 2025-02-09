import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/domain/presentation/pages/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async'; // Add this import
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_service.dart';

class TodoViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  Timer? _refreshTimer;

  String? selectedCategory = "Tümü"; // 📌 Varsayılan olarak tüm görevleri getir
  List<TodoModel> allTodos = []; // 📌 Backend'den gelen tüm görevler

  TodoViewModel(this._todoService) : super([]) {
    fetchTodos();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchTodos();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  /// Zaman bazlı filtreleme için yeni metod ekle
  List<TodoModel> getFilteredTasks(TaskFilter filter) {
    final now = DateTime.now();
    return state.where((task) {
      if (task.dueDate == null) return false;
      switch (filter) {
        case TaskFilter.today:
          return isSameDay(task.dueDate!, now);
        case TaskFilter.week:
          return task.dueDate!.isAfter(now.subtract(Duration(days: 1))) &&
              task.dueDate!.isBefore(now.add(Duration(days: 7)));
        case TaskFilter.month:
          return task.dueDate!.year == now.year &&
              task.dueDate!.month == now.month;
      }
    }).toList();
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
