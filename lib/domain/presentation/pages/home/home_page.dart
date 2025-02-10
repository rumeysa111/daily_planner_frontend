import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Görevlerim",
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.blue),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(ref, selectedFilter),
            if (todoViewModel.isLoading)
              Center(child: CircularProgressIndicator())
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
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add-task'),
          label: Text('Yeni Görev'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, TaskFilter selectedFilter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _buildFilterButtons(ref, selectedFilter),
    );
  }

  Widget _buildFilterButtons(WidgetRef ref, TaskFilter selectedFilter) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
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
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 22,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildViewOption(
            ref,
            TaskView.categorized,
            'Kategorili Görünüm',
            Icons.category_outlined,
            selectedView,
          ),
          SizedBox(width: 12),
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
          padding: EdgeInsets.symmetric(
              vertical: 12, horizontal: 8), // Reduced horizontal padding
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Add this line
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
              ),
              SizedBox(width: 4), // Reduced spacing
              Flexible(
                // Wrap with Flexible
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13, // Slightly reduced font size
                  ),
                  overflow: TextOverflow.ellipsis, // Add this
                  maxLines: 1, // Add this
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSectionWithAnimation(
          "Devam Eden Görevler",
          ongoingTasks,
          ref,
          "Devam eden görev bulunmuyor",
        ),
        SizedBox(height: 24),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_outlined,
              size: 48,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.blue[800],
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
