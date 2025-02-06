import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:mytodo_app/routes/routes.dart';
import 'package:mytodo_app/viewmodels/todo_viewmodel.dart';
import '../../theme/colors.dart';
import '../../widgets/category_card.dart';
import '../../widgets/task_item.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoViewModel = ref.watch(todoProvider.notifier); // 📌 ViewModel
    final tasks = ref.watch(todoProvider); // 📌 Filtrelenmiş görevler
    final selectedCategory = todoViewModel.selectedCategory; // 📌 Seçilen kategori

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildSearchBar(),
              SizedBox(height: 20),
              _buildSectionTitle("Kategoriler"),
              _buildCategoryList(ref,selectedCategory!), // 📌 Kategori Seçimi
              SizedBox(height: 20),
              _buildTaskSection(context),
              SizedBox(height: 10),
              Expanded(child: _buildTaskList(tasks)), // 📌 Backend'den gelen görevler gösteriliyor
            ],
          ),
        ),
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
                hintText: "Görevleri ve etkinlikleri ara",
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

  /// 📌 Kategorileri Listeleyen Widget
  Widget _buildCategoryList(WidgetRef ref,String selectedCategory) {
    final todoViewModel = ref.watch(todoProvider.notifier);
    final categories = ["Tümü", "Work", "Personal", "Shopping", "Health"];


    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        return GestureDetector(
          onTap: () {
            todoViewModel.setCategory(category); // 📌 Backend'den filtrelenmiş görevleri al
          },
          child: CategoryCard(
            title: category,
            icon: Icons.category,
            color: category == "Work"
                ? Colors.blue
                : category == "Personal"
                ? Colors.red
                : category == "Shopping"
                ? Colors.orange
                : category == "Health"
                ? Colors.pink
                : Colors.grey, // "Tümü" için gri renk
          ),
        );
      }).toList(),
    );
  }

  /// 📌 Görev Başlığı ve "Tümünü Gör" Butonu
  Widget _buildTaskSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle("Bugünün görevleri"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.alltask);
          },
          child: Text("Tüm görevleri gör", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  /// 📌 Görev Listesi
  Widget _buildTaskList(List<TodoModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          "Bu kategoride henüz görev yok.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(title: task.title, time: task.dueDate?.toString() ?? "Belirtilmemiş");
      },
    );
  }
}
