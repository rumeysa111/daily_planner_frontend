import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/todo_model.dart';
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
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 📌 Kategori İkonu (Backend'den gelen emoji veya string)
              Text(category.icon, style: TextStyle(fontSize: 24)), // ✅ `IconData` yerine `Text()` kullan

              SizedBox(width: 10),

              // 📌 Görev Başlığı
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),

          Row(
            children: [
              // 📌 Görevi Tamamlama Butonu
              IconButton(
                icon: Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
                color: Colors.green,
                onPressed: onComplete,
              ),

              // 📌 Görevi Silme Butonu
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
