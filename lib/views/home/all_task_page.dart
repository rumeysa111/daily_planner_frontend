import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:mytodo_app/routes/routes.dart';
import 'package:mytodo_app/viewmodels/todo_viewmodel.dart';

class AllTasksPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todoProvider); // ✅ Görevleri Riverpod'dan alıyoruz

    // 📌 Geciken ve tüm görevleri filtrele
    final now = DateTime.now();
    final overdueTasks = tasks.where((task) => task.dueDate != null && task.dueDate!.isBefore(now) && !task.isCompleted).toList();
    final allTasks = tasks; // Tüm görevler

    return Scaffold(
      appBar: AppBar(
        title: Text("All Tasks", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Geciken Görevler (Overdue)
            if (overdueTasks.isNotEmpty) ...[
              Text("Overdue", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(child: _buildTaskList(overdueTasks, isOverdue: true)),
              SizedBox(height: 16),
            ],

            // 📌 Tüm Görevler (All Tasks)
            Text("All Tasks", style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(child: _buildTaskList(allTasks)),
          ],
        ),
      ),

      // 📌 + GÖREV EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ Yeni görev ekleme sayfasına yönlendirme
          Navigator.pushNamed(context, AppRoutes.addtask);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 📌 GÖREV LİSTESİNİ OLUŞTURAN WIDGET
  Widget _buildTaskList(List<TodoModel> tasks, {bool isOverdue = false}) {
    return tasks.isEmpty
        ? Center(child: Text("Henüz eklenmiş görev yok.", style: TextStyle(fontSize: 16, color: Colors.grey)))
        : ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          color: isOverdue ? Colors.red[50] : Colors.blue[50],
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                // ✅ Görevi güncelle (Bunu daha sonra backend'e entegre edebiliriz)
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              task.dueDate != null
                  ? DateFormat("EEE, d MMM yyyy").format(task.dueDate!)
                  : "Belirtilmemiş",
            ),
          ),
        );
      },
    );
  }
}