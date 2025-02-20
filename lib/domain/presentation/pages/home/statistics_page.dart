import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
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
            style: TextStyle(color: AppColors.error),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
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
            style: TextStyle(
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
          title: "Streak",
          value: "${statistics.currentStreak} gün",
          icon: Icons.local_fire_department,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart(TaskStatistics statistics) {
    final List<String> weekDays = [
      'Pzt',
      'Sal',
      'Çar',
      'Per',
      'Cum',
      'Cmt',
      'Paz'
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Haftalık İlerleme",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.2, // Eksenin aralık değerini belirle
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                          ),
                        ));
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          weekDays[value.toInt()], // Haftalık günleri yazdır
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
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
                    return FlLine(
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

  Widget _buildCategoryCompletionChart(TaskStatistics statistics) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),

        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kategori Bazlı Tamamlanma",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: statistics.categoryCompletion.entries.map((entry) {
                  Color categoryColor = Colors.primaries[
                      entry.key.hashCode % Colors.primaries.length];
                  return PieChartSectionData(
                    color: categoryColor.withOpacity(0.8),
                    value: entry.value,
                    title: '${entry.value.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cardBackground,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Kategori lejantları
       Column(
            children: statistics.categoryCompletion.entries.map((entry) {
              Color categoryColor = Colors.primaries[
                  entry.key.hashCode % Colors.primaries.length];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
