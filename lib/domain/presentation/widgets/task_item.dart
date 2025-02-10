import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final categories = ref.watch(categoryProvider); // 📌 Tüm kategorileri al
    final category = categories.firstWhere(
      (cat) => cat.id == task.categoryId,
      orElse: () => CategoryModel(
        id: "0",
        name: "Unknown",
        icon: "❓",
        color: Colors.grey, // 🔥 Default renk düzeltildi
        userId: "", // Add this line
      ),
    );

    return GestureDetector(
      onTap: () => _showTaskDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              Colors.white, // Tamamlanan görevler için gri arka plan kaldırıldı
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
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
                      Text(category.icon, style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color:
                                task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        task.dueDate != null
                            ? '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'
                            : 'Tarih yok',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        task.time ?? 'Saat belirtilmedi',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onComplete(),
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
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
