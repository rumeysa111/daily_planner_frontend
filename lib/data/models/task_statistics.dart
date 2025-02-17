class TaskStatistics {
  final int completedTasks;
  final int totalTasks;
  final Map<String, double> categoryCompletion;
  final List<double> weeklyProgress;
  final int currentStreak;
  final int pendingTasks;
  final double completionRate;
  final Map<String, int> categoryDistribution;

  const TaskStatistics({
    required this.completedTasks,
    required this.totalTasks,
    required this.categoryCompletion,
    required this.weeklyProgress,
    required this.currentStreak,
    required this.pendingTasks,
    required this.completionRate,
    required this.categoryDistribution,
  });

  factory TaskStatistics.fromMap(Map<String, dynamic> map) {
    return TaskStatistics(
      completedTasks: map['completedTasks'] as int,
      totalTasks: map['totalTasks'] as int,
      categoryCompletion: Map<String, double>.from(map['categoryCompletion'].map((key, value) => MapEntry(key, value.toDouble()))),
      weeklyProgress: List<double>.from(map['weeklyProgress'].map((value) => value.toDouble())),
      currentStreak: map['currentStreak'] as int,
      pendingTasks: map['pendingTasks'] as int,
      completionRate: (map['completionRate'] as num).toDouble(),
      categoryDistribution: Map<String, int>.from(map['categoryDistribution']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'categoryCompletion': categoryCompletion,
      'weeklyProgress': weeklyProgress,
      'currentStreak': currentStreak,
      'pendingTasks': pendingTasks,
      'completionRate': completionRate,
      'categoryDistribution': categoryDistribution,
    };
  }
}