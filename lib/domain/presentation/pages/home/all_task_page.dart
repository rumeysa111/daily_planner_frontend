// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class AllTasksPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todoProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final overdueTasks = tasks
        .where((task) =>
            task.dueDate != null &&
            task.dueDate!.isBefore(now) &&
            !task.isCompleted)
        .toList();
    final allTasks = tasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Tüm Görevler",
        showLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overdueTasks.isNotEmpty) ...[
              Text(
                "Gecikmiş Görevler",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildTaskList(overdueTasks, isOverdue: true),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              "Tüm Görevler",
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskList(allTasks)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addtask),
        backgroundColor: AppColors.primary,
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 2,
      ),
    );
  }

  Widget _buildTaskList(List<TodoModel> tasks, {bool isOverdue = false}) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              "Henüz görev bulunmuyor",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue ? AppColors.error.withOpacity(0.3) : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: isOverdue
                    ? AppColors.error.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  // Handle task completion
                },
                activeColor: AppColors.success,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(
                  color: AppColors.divider,
                  width: 1.5,
                ),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  task.dueDate != null
                      ? DateFormat("EEE, d MMM yyyy").format(task.dueDate!)
                      : "Tarih belirtilmemiş",
                  style: TextStyle(
                    color: isOverdue ? AppColors.error : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                // Handle task options
              },
            ),
          ),
        );
      },
    );
  }
}