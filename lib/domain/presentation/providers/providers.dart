import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/data/models/category_model.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:mytodo_app/data/models/todo_model.dart';
import 'package:mytodo_app/data/models/user_model.dart';
import 'package:mytodo_app/data/repositories/auth_service.dart';
import 'package:mytodo_app/data/repositories/category_service.dart';
import 'package:mytodo_app/data/repositories/statistic_service.dart';
import 'package:mytodo_app/data/repositories/todo_service.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/todo_viewmodel.dart';

final authServiceProvider = Provider<AuthService>(
    (ref) {
      return AuthService();
    });

// Auth view model provider
final authProvider = StateNotifierProvider<AuthViewModel, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService, ref);
});
///  Riverpod Provider
final categoryProvider =
    StateNotifierProvider<CategoryViewModel, List<CategoryModel>>((ref) {
  return CategoryViewModel(CategoryService());
});
final todoProvider =
    StateNotifierProvider<TodoViewModel, List<TodoModel>>((ref) {
  return TodoViewModel(TodoService());
});
final calendarProvider =
    StateNotifierProvider<CalendarViewModel, List<TodoModel>>((ref) {
  return CalendarViewModel(TodoService());
});


final statisticsProvider = StateNotifierProvider<StatisticsViewModel, AsyncValue<TaskStatistics?>>((ref) {
  return StatisticsViewModel(StatisticsService())..loadStatistics();
});