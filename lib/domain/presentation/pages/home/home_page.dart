import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/task_item.dart';
import '../../widgets/custom_app_bar.dart';

enum TaskFilter { today, week, month }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.today);
final autoRefreshProvider = StateProvider<bool>((ref) => true); // Add this line

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoViewModel = ref.watch(todoProvider.notifier);
    final tasks = ref.watch(todoProvider); // Watch the tasks directly
    final selectedFilter = ref.watch(taskFilterProvider);
    final allTasks = todoViewModel.getFilteredTasks(selectedFilter);

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
            icon: Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.blue),
            onPressed: () {
              // Bildirimler fonksiyonu
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtre Butonları
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildFilterButtons(ref, selectedFilter),
                ],
              ),
            ),

            if (todoViewModel.isLoading)
              Center(child: CircularProgressIndicator())
            else if (tasks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz görev eklemediniz',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Yeni görev eklemek için + butonuna tıklayın',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Devam Eden Görevler Bölümü
                    _buildSectionHeader(
                        "Devam Eden Görevler", ongoingTasks.length),
                    if (ongoingTasks.isEmpty)
                      _buildEmptyState("Devam eden görev bulunmuyor")
                    else
                      _buildTasksList(ongoingTasks, ref),

                    SizedBox(height: 24),

                    // Tamamlanan Görevler Bölümü
                    _buildSectionHeader(
                        "Tamamlanan Görevler", completedTasks.length),
                    if (completedTasks.isEmpty)
                      _buildEmptyState("Tamamlanan görev bulunmuyor")
                    else
                      _buildTasksList(completedTasks, ref),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-task'),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Görevleri ara...",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(WidgetRef ref, TaskFilter selectedFilter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterButton(ref, TaskFilter.today, "Bugün", selectedFilter),
        _buildFilterButton(ref, TaskFilter.week, "Bu Hafta", selectedFilter),
        _buildFilterButton(ref, TaskFilter.month, "Bu Ay", selectedFilter),
      ],
    );
  }

  Widget _buildFilterButton(WidgetRef ref, TaskFilter filter, String label,
      TaskFilter selectedFilter) {
    final isSelected = selectedFilter == filter;

    return TextButton(
      onPressed: () {
        ref.read(taskFilterProvider.notifier).state = filter;
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
