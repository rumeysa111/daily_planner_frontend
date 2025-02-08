import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category_model.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategoryId; // ✅ Sadece kategori ID'si saklanacak
  CategoryModel? _selectedCategory; // ✅ UI'de göstermek için

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider); // 📌 Kategorileri al

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task",
            style: TextStyle(
                color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: Colors.red, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 GÖREV BAŞLIĞI
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Görev Başlığı",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 16),

            // 📌 KATEGORİ SEÇİMİ (Dropdown)
            Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: categories.isNotEmpty
                  ? categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Text(category.icon), // 📌 Kategori İkonu
                            SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList()
                  : [
                      DropdownMenuItem(
                        value: null,
                        child: Text("Kategori bulunamadı",
                            style: TextStyle(color: Colors.red)),
                      )
                    ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                  _selectedCategory = categories.firstWhere(
                      (cat) => cat.id == value,
                      orElse: () => CategoryModel(
                          id: "",
                          name: "Bilinmeyen",
                          icon: "?",
                          color: Colors.grey));
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),

            SizedBox(height: 16),

            // 📌 TARİH VE SAAT SEÇİMİ
            Text("Tarih ve Saat",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildDateButton(),
                SizedBox(width: 16),
                _buildTimeButton(),
              ],
            ),
            SizedBox(height: 16),

            // 📌 NOT EKLEME ALANI
            Text("Notlar", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Ek notlarınızı buraya yazın...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),

      // 📌 KAYDETME BUTONU
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveTask(ref),
        child: Icon(Icons.check),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 📌 TARİH SEÇİMİ BUTONU
  Widget _buildDateButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _pickDate,
        icon: Icon(Icons.calendar_today, color: Colors.orange),
        label: Text(_selectedDate == null
            ? "Tarih Seç"
            : DateFormat("dd/MM/yyyy").format(_selectedDate!)),
      ),
    );
  }

  // 📌 SAAT SEÇİMİ BUTONU
  Widget _buildTimeButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _pickTime,
        icon: Icon(Icons.access_time, color: Colors.red),
        label: Text(_selectedTime == null
            ? "Saat Seç"
            : _selectedTime!.format(context)),
      ),
    );
  }

  // 📌 TARİH SEÇME DİYALOĞU
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  // 📌 SAAT SEÇME DİYALOĞU
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
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
      print("🚨 Kullanıcı giriş yapmamış, `userId` bulunamadı!");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş yapmadan görev ekleyemezsiniz!")));
      return;
    }

    // 📌 `dueDate` ile `_selectedTime` birleştiriliyor.
    DateTime? fullDate;
    if (_selectedDate != null && _selectedTime != null) {
      fullDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else if (_selectedDate != null) {
      fullDate = _selectedDate; // Eğer sadece tarih seçildiyse
    }

    // 📌 Yeni görev objesi oluşturuyoruz
    TodoModel newTask = TodoModel(
      id: "",
      title: _titleController.text,
      categoryId: _selectedCategoryId!, // ✅ Sadece kategori ID'si kaydediliyor
      category: _selectedCategory, // ✅ UI'de kullanmak için
      dueDate: fullDate,
      time: _selectedTime?.format(context),
      notes: _notesController.text,
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );
    print("📌 Yeni görev oluşturuldu: ${newTask.toJson()}");

    // 📌 Görev eklendikten sonra anasayfaya dön
    ref.read(todoProvider.notifier).addTodo(newTask).then((_) {
      print("✅ Görev başarıyla eklendi!");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Görev başarıyla eklendi!")));

      // Kategorileri yeniden yükle
      ref.read(categoryProvider.notifier).fetchCategories();

      Navigator.pop(context);
    }).catchError((error) {
      print("🚨 Görev eklenirken hata oluştu: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Görev ekleme başarısız!")));
    });
  }
}
