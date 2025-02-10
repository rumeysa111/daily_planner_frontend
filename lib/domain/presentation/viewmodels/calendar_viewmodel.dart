import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CalendarViewModel extends StateNotifier<List<TodoModel>> {
  final TodoService _todoService;
  DateTime _selectedDate = DateTime.now();
  Timer? _refreshTimer;
  bool isLoading = false;

  DateTime get selectedDate => _selectedDate;

  CalendarViewModel(this._todoService) : super([]) {
    fetchTodosByDate(_selectedDate);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchTodosByDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchTodosByDate(DateTime date) async {
    if (isLoading) return;

    isLoading = true;
    state = []; // Yükleme başlamadan önce mevcut state'i temizle

    final token = await _getToken();
    if (token == null) {
      isLoading = false;
      return;
    }

    try {
      final todos = await _todoService.fetchTodosByDate(token, date);
      if (!mounted) return; // StateNotifier dispose edilmişse işlemi iptal et

      state = todos;
      _selectedDate = date;
      print(
          "📅 Fetched ${todos.length} tasks for ${date.toString().split(' ')[0]}");
    } catch (e) {
      print("🚨 Calendar tasks fetch error: $e");
      if (mounted) {
        state = [];
      }
    } finally {
      isLoading = false;
    }
  }

  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      fetchTodosByDate(date);
    }
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarViewModel, List<TodoModel>>((ref) {
  return CalendarViewModel(TodoService());
});
