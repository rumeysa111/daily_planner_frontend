import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:mytodo_app/data/repositories/statistic_service.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/todo_viewmodel.dart';

final statisticsProvider =
    StateNotifierProvider<StatisticsViewModel, TaskStatistics?>((ref) {
  final viewModel = StatisticsViewModel(
    StatisticsService(),
    ref.watch(todoProvider.notifier),
  );
  // Provider oluşturulduğunda istatistikleri otomatik yükle
  viewModel.loadStatistics();
  return viewModel;
});

class StatisticsViewModel extends StateNotifier<TaskStatistics?> {
  final StatisticsService _statisticsService;
  final TodoViewModel _todoViewModel;
  bool _isLoading = false;

  StatisticsViewModel(this._statisticsService, this._todoViewModel)
      : super(null);

  Future<void> loadStatistics() async {
    if (_isLoading) return; // Eğer zaten yükleniyorsa, tekrar yükleme

    _isLoading = true;
    try {
      final tasks = _todoViewModel.state;
      final statistics = await _statisticsService.calculateStatistics(tasks);
      state = statistics;
    } catch (e) {
      print('Error loading statistics: $e');
      state = null;
    } finally {
      _isLoading = false;
    }
  }
}
