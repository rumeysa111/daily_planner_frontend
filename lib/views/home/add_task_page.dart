import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mytodo_app/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _selectedCategory = "Work";
  String? _selectedReminder;
  String _selectedColor = "#7D4CDB"; // Default mor renk

  final List<String> categories = ["Work", "Personal", "Shopping", "Health"];
  final List<Color> colors = [Colors.purple, Colors.blue, Colors.pink, Colors.green, Colors.teal];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
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
                hintText: "Finish Report",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 16),

            // 📌 KATEGORİ SEÇİMİ (Dropdown)
            Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            SizedBox(height: 16),

            // 📌 TARİH VE SAAT SEÇİMİ
            Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildDateButton(),
                SizedBox(width: 16),
                _buildTimeButton(),
              ],
            ),
            SizedBox(height: 16),

            // 📌 HATIRLATMA SEÇİMİ
            Text("Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildReminderButton(),
            SizedBox(height: 16),

            // 📌 RENK SEÇİMİ
            Text("Renk", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color.value.toRadixString(16)),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color.value.toRadixString(16)
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // 📌 NOT EKLEME ALANI
            Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Make sure to research from internet",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),

      // 📌 KAYDETME BUTONU (Floating Action Button - Mavi Tik)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveTask(ref), // ✅ `ref` eklenerek düzeltildi
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
        label: Text(_selectedDate == null ? "Set due date" : DateFormat("dd/MM/yyyy").format(_selectedDate!)),
      ),
    );
  }

  // 📌 SAAT SEÇİMİ BUTONU
  Widget _buildTimeButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _pickTime,
        icon: Icon(Icons.access_time, color: Colors.red),
        label: Text(_selectedTime == null ? "Set Time" : _selectedTime!.format(context)),
      ),
    );
  }

  // 📌 HATIRLATMA SEÇİMİ BUTONU
  Widget _buildReminderButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Hatırlatma ekleme fonksiyonu
      },
      icon: Icon(Icons.notifications, color: Colors.red),
      label: Text(_selectedReminder ?? "Set Reminder"),
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
  void _saveTask(WidgetRef ref) async { // ✅ `ref` burada kullanılacak şekilde güncellendi
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen görev başlığını girin!")));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    if (userId == null || userId.isEmpty) {
      print("🚨 Kullanıcı giriş yapmamış, `userId` bulunamadı!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Giriş yapmadan görev ekleyemezsiniz!")));
      return;
    }
    // 📌 Yeni görev objesi oluşturuyoruz
    TodoModel newTask = TodoModel(
      id: "",
      title: _titleController.text,
      category: _selectedCategory,
      dueDate: _selectedDate,
      color: _selectedColor,
      notes: _notesController.text,
      isCompleted: false,
      userId:userId,
      createdAt: DateTime.now(),
    );
    print("📌 Yeni görev oluşturuldu: ${newTask.toJson()}");

    // 📌 Görevi ViewModel üzerinden backend'e ekle
    ref.read(todoProvider.notifier).addTodo(newTask);

    // 📌 Görev eklendikten sonra anasayfaya dön
    // 📌 Görevi ViewModel üzerinden backend'e ekle
    ref.read(todoProvider.notifier).addTodo(newTask).then((_) {
      print("✅ Görev başarıyla eklendi!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Görev başarıyla eklendi!")));
    }).catchError((error) {
      print("🚨 Görev eklenirken hata oluştu: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Görev ekleme başarısız!")));
    });
  }
  }
