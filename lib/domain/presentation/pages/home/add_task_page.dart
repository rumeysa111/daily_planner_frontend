import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    _selectedDate = widget.selectedDate ?? DateTime.now(); // 📌 Varsayılan olarak bugünü al
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Görev Ekle", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
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

  // 📌 Kategori Seçimi
  Widget _buildCategoryDropdown(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Text(category.icon),
                  SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              _selectedCategory = categories.firstWhere((cat) => cat.id == value);
            });
          },
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen görev başlığını girin!")));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen bir kategori seçin!")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Giriş yapmadan görev ekleyemezsiniz!")));
      return;
    }

    // 📌 Eğer saat seçilmezse, o günün tümü için görev kabul edilir
    DateTime fullDate = _selectedDate!;
    if (_selectedTime != null) {
      fullDate = DateTime(fullDate.year, fullDate.month, fullDate.day, _selectedTime!.hour, _selectedTime!.minute);
    }

    TodoModel newTask = TodoModel(
      id: "",
      title: _titleController.text,
      categoryId: _selectedCategoryId!,
      category: _selectedCategory,
      dueDate: fullDate,
      time: _selectedTime?.format(context),
      notes: _notesController.text,
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );

    ref.read(todoProvider.notifier).addTodo(newTask);
    Navigator.pop(context);
  }
}
