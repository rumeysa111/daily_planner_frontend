class TaskStatistics {
  final int completedTasks;
  final int totalTasks;
  final Map<String, double> categoryCompletion;
  final Map<int, int> hourlyCompletion;
  final List<double> weeklyProgress;
  final int currentStreak;
  final int pendingTasks;
  final double completionRate;
  final Map<String, int> categoryDistribution;

  TaskStatistics({
    required this.completedTasks,
    required this.totalTasks,
    required this.categoryCompletion,
    required this.hourlyCompletion,
    required this.weeklyProgress,
    required this.currentStreak,
    required this.pendingTasks,
    required this.completionRate,
    required this.categoryDistribution,
  });
}
