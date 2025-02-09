import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  DateTime selectedDate = DateTime.now();

  CalendarViewModel(this._todoService) : super([]) {
    fetchTodosByDate(selectedDate);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

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
    } catch (e) {
      print("🚨 Takvim görevlerini çekerken hata: $e");
      state = [];
    }
  }

  void setSelectedDate(DateTime date) {
    fetchTodosByDate(date);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarViewModel, List<TodoModel>>((ref) {
  return CalendarViewModel(TodoService());
});
