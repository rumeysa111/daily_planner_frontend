// ignore_for_file: unused_import, deprecated_member_use, sized_box_for_whitespace, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/data/models/category_model.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:mytodo_app/domain/presentation/providers/providers.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/statistics_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(statisticsProvider.notifier).loadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "İstatistikler",
        showLeading: false,
      ),
      body: statistics.when(
        data: (data) {
          if (data == null) {
            return _buildEmptyState();
          }
          return _buildContent(data);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Hata: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TaskStatistics statistics) {
    if (statistics.totalTasks == 0) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewCards(statistics),
          const SizedBox(height: 24),
          _buildWeeklyProgressChart(statistics),
          const SizedBox(height: 24),
          _buildCategoryCompletionChart(statistics),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Henüz istatistik gösterilecek görev bulunmuyor',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(TaskStatistics statistics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatisticCard(
          title: "Tamamlanan Görevler",
          value: statistics.completedTasks.toString(),
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        _buildStatisticCard(
          title: "Bekleyen Görevler",
          value: statistics.pendingTasks.toString(),
          icon: Icons.pending,
          color: AppColors.warning,
        ),
        _buildStatisticCard(
          title: "Tamamlanma Oranı",
          value: "${statistics.completionRate.toStringAsFixed(1)}%",
          icon: Icons.pie_chart,
          color: AppColors.primary,
        ),
        _buildStatisticCard(
          title: "Seri",
          value: "${statistics.currentStreak} gün",
          icon: Icons.local_fire_department,
          color: AppColors.error,
        ),
      ],
    );
  }

 Widget _buildWeeklyProgressChart(TaskStatistics statistics) {
  final List<String> weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  // 🔹 Debug: Haftalık ilerleme verisini terminale yazdır
  print("Weekly Progress Data: ${statistics.weeklyProgress}");

  if (statistics.weeklyProgress.isEmpty ||
      statistics.weeklyProgress.every((element) => element == 0)) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Haftalık İlerleme",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: Text("Bu hafta için tamamlanan görev yok")),
        ],
      ),
    );
  } else {
    // 🔹 Eğer `weeklyProgress` doluysa grafik gösterilecek!
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Haftalık İlerleme",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: statistics.weeklyProgress.isEmpty
                    ? 1
                    : statistics.weeklyProgress.reduce((a, b) => a > b ? a : b) + 0.1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.2,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          weekDays[value.toInt()],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  border: const Border(
                    bottom: BorderSide(color: AppColors.divider),
                    left: BorderSide(color: AppColors.divider),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: statistics.weeklyProgress.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: AppColors.primary,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _buildCategoryCompletionChart(TaskStatistics statistics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kategori Bazlı Tamamlanma",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sections: statistics.categoryCompletion.entries.map((entry) {
                  // AppColors.categoryColors'dan renk al
                  final colorIndex =
                      entry.key.hashCode % AppColors.categoryColors.length;
                  final categoryColor = AppColors.categoryColors[colorIndex];

                  return PieChartSectionData(
                    color: categoryColor.withOpacity(0.8),
                    value: entry.value,
                    title: '', // Dilim üzerindeki yazıyı kaldır
                    radius: 80, // Daire boyutunu küçült
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cardBackground,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kategori lejantlarını kaydırılabilir yap
          Container(
            height: 120,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: statistics.categoryCompletion.entries.map((entry) {
                  final colorIndex =
                      entry.key.hashCode % AppColors.categoryColors.length;
                  final categoryColor = AppColors.categoryColors[colorIndex];

                  // Kategori adını bulmak için ref.watch(categoryProvider) kullan
                  final categories = ref.watch(categoryProvider);
                  final categoryName = categories
                      .firstWhere((cat) => cat.id == entry.key,
                          orElse: () => CategoryModel(
                              id: entry.key,
                              name: "Bilinmeyen Kategori",
                              icon: "❓",
                              color: AppColors.textSecondary,
                              userId: ""))
                      .name;

                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$categoryName (${entry.value.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
