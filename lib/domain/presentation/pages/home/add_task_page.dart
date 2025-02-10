import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/widgets/category_edit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/date_time_picker.dart'; // 📌 Yeni Widget'ı içeri aktar

class AddTaskPage extends ConsumerStatefulWidget {
  final DateTime? selectedDate; // 📌 Seçili tarih (Takvim sayfasından gelirse)

  AddTaskPage({Key? key, this.selectedDate}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategoryId;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.selectedDate ?? DateTime.now(); // 📌 Varsayılan olarak bugünü al
    // Kategorileri yenile
    Future.microtask(() {
      ref.read(categoryProvider.notifier).fetchCategories();
    });
  }

  // Kategori seçimi için yeni method
  void _showAddCategoryDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(),
    );

    if (result == true) {
      // Yeni kategori eklendiyse kategorileri yenile
      await ref.read(categoryProvider.notifier).fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Görev Ekle",
            style: TextStyle(
                color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Henüz kategori eklenmemiş'),
                  ElevatedButton(
                    onPressed: _showAddCategoryDialog,
                    child: Text('Kategori Ekle'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(),
                  SizedBox(height: 16),
                  _buildCategoryDropdown(categories),
                  SizedBox(height: 16),
                  _buildDateTimePicker(),
                  SizedBox(height: 16),
                  _buildNotesField(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveTask(ref),
        child: Icon(Icons.check),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 📌 Görev Başlığı Alanı
  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: "Görev Başlığı",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 📌 Yeni Kategori Seçim UI'ı
  Widget _buildCategoryDropdown(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategori",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 100, // Yüksekliği ayarlayabilirsiniz
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategoryId == category.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? category.color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? category.color : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 📌 Tarih & Saat Seçimi (Yeni Widget Kullanımı)
  Widget _buildDateTimePicker() {
    return DateTimePicker(
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      onDateSelected: (date) => setState(() => _selectedDate = date),
      onTimeSelected: (time) => setState(() => _selectedTime = time),
    );
  }

  // 📌 Notlar Alanı
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Notlar", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Ek notlarınızı buraya yazın...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // 📌 Görevi Kaydetme
  void _saveTask(WidgetRef ref) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen görev başlığını girin!")));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lütfen bir kategori seçin!")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş yapmadan görev ekleyemezsiniz!")));
      return;
    }

    // 📌 Eğer saat seçilmezse, varsayılan olarak 00:00 ata
    DateTime fullDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime?.hour ?? 0,
      _selectedTime?.minute ?? 0,
    ).toLocal(); // Yerel saat dilimine çevir

    TodoModel newTask = TodoModel(
      id: "",
      title: _titleController.text,
      categoryId: _selectedCategoryId!,
      category: _selectedCategory,
      dueDate: fullDate, // Artık her zaman bir tarih olacak
      time: _selectedTime?.format(context) ??
          "Tüm gün", // Saat seçilmediyse "Tüm gün" olarak belirt
      notes: _notesController.text,
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );

    await ref.read(todoProvider.notifier).addTodo(newTask);

    // Calendar provider'ı da güncelle
    if (widget.selectedDate != null) {
      ref
          .read(calendarProvider.notifier)
          .fetchTodosByDate(widget.selectedDate!);
    }

    Navigator.pop(context);
  }
}
