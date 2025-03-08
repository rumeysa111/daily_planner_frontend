// ignore_for_file: unused_import, deprecated_member_use, sized_box_for_whitespace, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/domain/presentation/providers/providers.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/task_item.dart';
import '../../widgets/custom_app_bar.dart';

enum TaskFilter { today, week, month }

enum TaskView { categorized, all } // Add view type enum

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.today);
final autoRefreshProvider = StateProvider<bool>((ref) => true); // Add this line

class HomePage extends ConsumerWidget {
  static final taskViewProvider = StateProvider<TaskView>(
      (ref) => TaskView.categorized); // Add view type provider

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final todoViewModel = ref.watch(todoProvider.notifier);
    final theme = Theme.of(context);
    final tasks = ref.watch(todoProvider); // Watch the tasks directly
    final selectedFilter = ref.watch(taskFilterProvider);
    final allTasks = todoViewModel.getFilteredTasks(selectedFilter);
    final selectedView = ref.watch(taskViewProvider); // Add view type provider

    // Add auto-refresh listener
    ref.listen<bool>(autoRefreshProvider, (previous, next) {
      if (next) {
        todoViewModel.fetchTodos();
      }
    });

    // Görevleri tamamlanmış ve devam eden olarak ayır
    final ongoingTasks = allTasks.where((task) => !task.isCompleted).toList();
    final completedTasks = allTasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Ana Sayfa',
        showLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ref, selectedFilter),
                if (todoViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (tasks.isEmpty)
                  _buildEmptyState("Henüz görev eklemediniz",
                      "Yeni görev eklemek için + butonuna tıklayın")
                else
                  Expanded(
                    child: Column(
                      children: [
                        _buildViewSelector(ref),
                        Expanded(
                          child: selectedView == TaskView.categorized
                              ? _buildCategorizedView(
                                  ongoingTasks, completedTasks, ref)
                              : _buildAllTasksView(allTasks, ref),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addtask),
          label: const Text(
            'Yeni Görev',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, TaskFilter selectedFilter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _buildFilterButtons(ref, selectedFilter),
    );
  }

  Widget _buildFilterButtons(WidgetRef ref, TaskFilter selectedFilter) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            ref,
            TaskFilter.today,
            "Bugün",
            selectedFilter,
            Icons.today,
          ),
          _buildFilterButton(
            ref,
            TaskFilter.week,
            "Bu Hafta",
            selectedFilter,
            Icons.calendar_view_week,
          ),
          _buildFilterButton(
            ref,
            TaskFilter.month,
            "Bu Ay",
            selectedFilter,
            Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(WidgetRef ref, TaskFilter filter, String label,
      TaskFilter selectedFilter, IconData icon) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(taskFilterProvider.notifier).state = filter,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewSelector(WidgetRef ref) {
    final selectedView = ref.watch(taskViewProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildViewOption(
            ref,
            TaskView.categorized,
            'Kategorili Görünüm',
            Icons.category_outlined,
            selectedView,
          ),
          const SizedBox(width: 12),
          _buildViewOption(
            ref,
            TaskView.all,
            'Tüm Görevler',
            Icons.list_outlined,
            selectedView,
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption(
    WidgetRef ref,
    TaskView view,
    String label,
    IconData icon,
    TaskView selectedView,
  ) {
    final isSelected = selectedView == view;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(taskViewProvider.notifier).state = view,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorizedView(List<TodoModel> ongoingTasks,
      List<TodoModel> completedTasks, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSectionWithAnimation(
          "Devam Eden Görevler",
          ongoingTasks,
          ref,
          "Devam eden görev bulunmuyor",
        ),
        const SizedBox(height: 24),
        _buildSectionWithAnimation(
          "Tamamlanan Görevler",
          completedTasks,
          ref,
          "Tamamlanan görev bulunmuyor",
        ),
      ],
    );
  }

  Widget _buildAllTasksView(List<TodoModel> allTasks, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSectionWithAnimation(
          "Tüm Görevler",
          allTasks,
          ref,
          "Görev bulunmuyor",
        ),
      ],
    );
  }

  Widget _buildSectionWithAnimation(
      String title, List<TodoModel> tasks, WidgetRef ref, String emptyMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, tasks.length),
        tasks.isEmpty
            ? Center(
                child: Container(
                  width: double.infinity,
                  child: _buildEmptyState(emptyMessage, ""),
                ),
              )
            : _buildTasksList(tasks, ref),
      ],
    );
  }

  Widget _buildEmptyState([String message = "", String subtitle = ""]) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<TodoModel> tasks, WidgetRef ref) {
    return Column(
      children: tasks
          .map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TaskItem(
                  task: task,
                  time: task.time ?? "Belirtilmemiş",
                  onComplete: () {
                    ref
                        .read(todoProvider.notifier)
                        .toggleTaskCompletion(task.id);
                  },
                  onDelete: () {
                    ref.read(todoProvider.notifier).deleteTodo(task.id);
                  },
                ),
              ))
          .toList(),
    );
  }
}
