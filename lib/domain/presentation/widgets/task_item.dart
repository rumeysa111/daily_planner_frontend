import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import '../../../data/models/category_model.dart';
import 'task_detail_popup.dart';
import '../../../data/models/todo_model.dart';
import '../viewmodels/category_viewmodel.dart';

class TaskItem extends ConsumerWidget {
  final TodoModel task;
  final String time;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskItem({
    required this.task,
    required this.time,
    required this.onComplete,
    required this.onDelete,
  });

 @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoryProvider);
    final category = categories.firstWhere(
      (cat) => cat.id == task.categoryId,
      orElse: () => CategoryModel(
        id: "0",
        name: "Unknown",
        icon: "❓",
        color: AppColors.textSecondary,
        userId: "",
      ),
    );

    return GestureDetector(
      onTap: () => _showTaskDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.icon,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        task.dueDate != null
                            ? '${task.dueDate!.toLocal().day}/${task.dueDate!.toLocal().month}/${task.dueDate!.toLocal().year}'
                            : 'Tarih yok',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        task.time ?? 'Saat belirtilmedi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onComplete(),
                    activeColor: AppColors.success,
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: AppColors.divider,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                  splashRadius: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailPopup(task: task),
    ).then((updated) {
      if (updated == true) {
        // Task was updated, trigger any necessary refresh
      }
    });
  }
}
