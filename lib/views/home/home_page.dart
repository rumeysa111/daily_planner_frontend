import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:mytodo_app/routes/routes.dart';
import 'package:mytodo_app/viewmodels/todo_viewmodel.dart';
import '../../theme/colors.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/category_card.dart';
import '../../widgets/task_item.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoViewModel = ref.watch(todoProvider.notifier); // 📌 ViewModel
    final todayTasks = ref.watch(todoProvider); // 📌 Anlık görev listesi
final ongoingTasks=todayTasks.where((task)=> !task.isCompleted).toList();
final completedTasks=todayTasks.where((task)=>task.isCompleted).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Görevler", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildSearchBar(),

              SizedBox(height: 20),
              _buildTaskSection("Bugünün Görevleri ",ongoingTasks,ref),
              SizedBox(height: 10),
              //tamamamlana görevler
              _buildTaskSection("Tamamlanan Görevler",completedTasks,ref),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addtask);
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// 📌 Arama Çubuğu
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

  /// 📌 Bölüm Başlığı
  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }



  /// 📌 Görev Bölümü (Tamamlanan ve Devam Edenler İçin Kullanılır)
  Widget _buildTaskSection(String title, List<TodoModel> tasks, WidgetRef ref, {bool completed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (tasks.isNotEmpty)
              TextButton(
                onPressed: () {
          //        Navigator.pushNamed(context , AppRoutes.alltask);
                },
                child: Text("Tümünü Gör", style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
        SizedBox(height: 10),
        _buildTaskList(tasks, ref, completed),
      ],
    );
  }
  /// 📌 Görev Listesi
  Widget _buildTaskList(List<TodoModel> tasks, WidgetRef ref, bool completed) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          completed ? "Tamamlanmış görev yok." : "Bugün için görev yok.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        // 📌 Saat formatlama (HH:mm)
        String formattedTime = task.dueDate != null
            ? DateFormat("HH:mm").format(task.dueDate!)
            : "Belirtilmemiş";

        return TaskItem(
          task: task,
          time: formattedTime,
          onComplete: () {
            ref.read(todoProvider.notifier).toggleTaskCompletion(task.id);
          },
          onDelete: () {
            ref.read(todoProvider.notifier).deleteTodo(task.id);
          },
        );
      },
    );
  }
}
