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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Yeni Görev",
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categories.isEmpty
          ? _buildEmptyCategoryState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        SizedBox(height: 24),
                        _buildCategoryDropdown(categories),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateTimePicker(),
                        SizedBox(height: 24),
                        _buildNotesField(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveTask(ref),
        label: Text('Kaydet'),
        icon: Icon(Icons.check),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEmptyCategoryState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.category_outlined, size: 48, color: Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz kategori eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: Icon(Icons.add),
              label: Text('Kategori Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Görev Başlığı",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: "Görevinizi yazın",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  // 📌 Yeni Kategori Seçim UI'ı
  Widget _buildCategoryDropdown(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Kategori",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: Icon(Icons.add, size: 18),
              label: Text("Yeni"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxHeight: 200), // Maximum yükseklik
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8, // yatay boşluk
              runSpacing: 8, // dikey boşluk
              children: categories.map((category) {
                final isSelected = _selectedCategoryId == category.id;

                return Container(
                  width: (MediaQuery.of(context).size.width - 64) /
                      4, // 4 item per row
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.icon,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  isSelected ? category.color : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
      onDateSelected: (date) {
        // Geçmiş tarihleri kontrol et
        if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Geçmiş tarihlere görev eklenemez!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() => _selectedDate = date);
      },
      onTimeSelected: (time) => setState(() => _selectedTime = time),
    );
  }

  // 📌 Notlar Alanı
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notlar",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Ek notlarınızı buraya yazın...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  // 📌 Görevi Kaydetme
  void _saveTask(WidgetRef ref) async {
    // Tarih kontrolü ekle
    if (_selectedDate!.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geçmiş tarihlere görev eklenemez!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
