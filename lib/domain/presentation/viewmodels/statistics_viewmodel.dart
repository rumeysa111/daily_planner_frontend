import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:mytodo_app/data/repositories/statistic_service.dart';

class StatisticsViewModel extends StateNotifier<AsyncValue<TaskStatistics?>> {
  final StatisticsService _statisticsService;

  StatisticsViewModel(this._statisticsService) : super(const AsyncValue.loading());

  Future<void> loadStatistics() async {
    state = const AsyncValue.loading();
    try {
      final statistics = await _statisticsService.getStatistics();
      state = AsyncValue.data(statistics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

