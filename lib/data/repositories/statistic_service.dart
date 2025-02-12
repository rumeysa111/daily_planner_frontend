import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:mytodo_app/data/models/todo_model.dart';

class StatisticsService {
  Future<TaskStatistics> calculateStatistics(List<TodoModel> tasks) async {
    // Temel istatistikler
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final totalTasks = tasks.length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    // Kategori bazlı tamamlanma oranları
    Map<String, double> categoryCompletion = {};
    Map<String, int> categoryDistribution = {};

    // Kategori istatistiklerini hesapla
    for (var task in tasks) {
      final categoryId = task.categoryId;
      categoryDistribution[categoryId] =
          (categoryDistribution[categoryId] ?? 0) + 1;

      if (task.isCompleted) {
        categoryCompletion[categoryId] =
            (categoryCompletion[categoryId] ?? 0) + 1;
      }
    }

    // Kategori tamamlanma oranlarını hesapla
    categoryCompletion.forEach((key, value) {
      final total = categoryDistribution[key] ?? 0;
      categoryCompletion[key] = total > 0 ? (value / total) * 100 : 0;
    });

    // Saatlik tamamlanma dağılımı
    Map<int, int> hourlyCompletion = {};
    for (var task in tasks.where((t) => t.isCompleted)) {
      if (task.dueDate != null) {
        final hour = task.dueDate!.hour;
        hourlyCompletion[hour] = (hourlyCompletion[hour] ?? 0) + 1;
      }
    }

    // Haftalık ilerleme
    List<double> weeklyProgress = _calculateWeeklyProgress(tasks);

    // Streak hesaplama
    final currentStreak = _calculateStreak(tasks);

    return TaskStatistics(
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      categoryCompletion: categoryCompletion,
      hourlyCompletion: hourlyCompletion,
      weeklyProgress: weeklyProgress,
      currentStreak: currentStreak,
      pendingTasks: pendingTasks,
      completionRate: completionRate,
      categoryDistribution: categoryDistribution,
    );
  }

  List<double> _calculateWeeklyProgress(List<TodoModel> tasks) {
    List<double> progress = List.filled(7, 0);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayTasks = tasks.where((task) =>
          task.dueDate?.year == day.year &&
          task.dueDate?.month == day.month &&
          task.dueDate?.day == day.day);

      if (dayTasks.isNotEmpty) {
        final completed = dayTasks.where((task) => task.isCompleted).length;
        progress[i] = completed / dayTasks.length;
      }
    }

    return progress;
  }

  int _calculateStreak(List<TodoModel> tasks) {
    int streak = 0;
    final now = DateTime.now();
    var currentDate = now;

    while (true) {
      final dayTasks = tasks.where((task) =>
          task.dueDate?.year == currentDate.year &&
          task.dueDate?.month == currentDate.month &&
          task.dueDate?.day == currentDate.day);

      if (dayTasks.isEmpty || !dayTasks.every((task) => task.isCompleted)) {
        break;
      }

      streak++;
      currentDate = currentDate.subtract(Duration(days: 1));
    }

    return streak;
  }
}
