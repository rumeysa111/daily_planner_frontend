// ignore_for_file: unused_local_variable, use_rethrow_when_possible

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/domain/presentation/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Add this import
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_service.dart';

class TodoViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  Timer? _refreshTimer;

  String? selectedCategory = "Tümü"; // 📌 Varsayılan olarak tüm görevleri getir
  List<TodoModel> allTodos = []; // 📌 Backend'den gelen tüm görevler
  bool isLoading = false;



  TodoViewModel(this._todoService) : super([]) {
    fetchTodos();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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
      // ignore: avoid_print
      print("🚨 Token alınırken hata oluştu: $e");
      return null;
    }
  }

  Future<void> fetchTodos({String? category}) async {
    isLoading = true;
    final token = await _getToken();
    if (token == null) {
      if (kDebugMode) {
        print("🚨 Kullanıcı giriş yapmamış, token bulunamadı");
      }
      state = [];
      isLoading = false;
      return;
    }
    try {
      final todos = await _todoService.fetchTodos(token, category: category);
      allTodos = todos;
      state = todos; // StateNotifier will automatically notify listeners
      if (kDebugMode) {
        print("✅ Görevler güncellendi: ${todos.length} görev var.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Görevleri çekerken hata oluştu: $e");
      }
      state = [];
    } finally {
      isLoading = false;
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
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final endOfWeek = startOfToday.add(const Duration(days: 7));
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return state.where((task) {
      if (task.dueDate == null) return false;

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      switch (filter) {
        case TaskFilter.today:
          return taskDate.isAtSameMomentAs(startOfToday);
        case TaskFilter.week:
          return taskDate.isAfter(startOfToday.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(endOfWeek);
        case TaskFilter.month:
          return taskDate.isAfter(startOfToday.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(endOfMonth);
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
            // ignore: unnecessary_to_list_in_spreads
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

    // Mevcut task'ı bul
    final taskIndex = state.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    try {
      // Yeni durumu oluştur
      final currentTask = state[taskIndex];
      final updatedTask = currentTask.copyWith(
        isCompleted: !currentTask.isCompleted,
      );

      // Önce backend'i güncelle
      await _todoService.updateTodo(token, taskId, updatedTask);

      // Backend başarılı olduysa state'i güncelle
      state = [
        ...state.sublist(0, taskIndex),
        updatedTask,
        ...state.sublist(taskIndex + 1),
      ];

      // allTodos listesini de güncelle
      final allTodosIndex = allTodos.indexWhere((task) => task.id == taskId);
      if (allTodosIndex != -1) {
        allTodos = [
          ...allTodos.sublist(0, allTodosIndex),
          updatedTask,
          ...allTodos.sublist(allTodosIndex + 1),
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Görev güncellenirken hata: $e");
      }
      // Hata durumunda kullanıcıya bilgi verilebilir
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    final token = await _getToken();
    if (token == null) {
      if (kDebugMode) {
        print("token bulunamadı");
      }
      return;
    }


    try {
      if (kDebugMode) {
        print("📌 Backend'e görev ekleniyor: ${todo.toJson()}");
      }
      bool success = await _todoService.addTodo(token, todo);

      if (success) {
        if (kDebugMode) {
          print("✅ Görev başarıyla eklendi");
        }
        // Backend'den güncel listeyi al
        await fetchTodos();

        // Eğer bir kategori seçiliyse, o kategoriye göre filtrele
        if (selectedCategory != "Tümü") {
          filterTodos();
        }
      } else {
        if (kDebugMode) {
          print("🚨 Görev ekleme başarısız!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Görev eklerken hata: $e");
      }
    }
  }

  Future<bool> deleteTodo(String id) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      // Backend'e silme isteği gönder
      bool success = await _todoService.deleteTodo(token, id);

      if (success) {
        // Backend'den silme başarılı olduysa state'i güncelle
        state = List.from(state.where((task) => task.id != id));
        allTodos = List.from(allTodos.where((task) => task.id != id));
        if (kDebugMode) {
          print("✅ Görev başarıyla silindi: $id");
        }
        return true;
      } else {
        if (kDebugMode) {
          if (kDebugMode) {
            if (kDebugMode) {
              print("🚨 Görev silme başarısız oldu!");
            }
          }
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Görev silinirken hata oluştu: $e");
      }
      return false;
    }
  }

  Future<void> updateTodo(String taskId, TodoModel updatedTask) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      // Backend'i güncelle
      await _todoService.updateTodo(token, taskId, updatedTask);

      // State'i güncelle
      state = state.map((task) {
        if (task.id == taskId) {
          return updatedTask;
        }
        return task;
      }).toList();

      // allTodos listesini de güncelle
      allTodos = allTodos.map((task) {
        if (task.id == taskId) {
          return updatedTask;
        }
        return task;
      }).toList();

      if (kDebugMode) {
        print("✅ Görev başarıyla güncellendi: $taskId");
      }
    } catch (e) {
      if (kDebugMode) {
        print(" Görev güncellenirken hata: $e");
      }
      throw e; // Re-throw to handle in UI
    }
  }
}

