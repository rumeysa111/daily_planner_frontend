import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/todo_viewmodel.dart';

class TaskDetailPopup extends ConsumerStatefulWidget {
  final TodoModel task;

  const TaskDetailPopup({required this.task});

  @override
  _TaskDetailPopupState createState() => _TaskDetailPopupState();
}

class _TaskDetailPopupState extends ConsumerState<TaskDetailPopup> {
  late TextEditingController _titleController;
  late TextEditingController _notesController; // Add this line
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late String _selectedCategoryId;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController =
        TextEditingController(text: widget.task.notes ?? ''); // Add this line
    _selectedDate = widget.task.dueDate ?? DateTime.now();
    _selectedTime = widget.task.time != null && widget.task.time != "Tüm gün"
        ? TimeOfDay.fromDateTime(
            DateTime.parse("2023-01-01 ${widget.task.time}:00"))
        : null;
    _selectedCategoryId = widget.task.categoryId;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose(); // Add this line
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final selectedCategory = categories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => CategoryModel(
        id: "0",
        name: "Unknown",
        icon: "❓",
        color: Colors.grey,
        userId: "",
      ),
    );

    return Dialog(
      backgroundColor: Colors.grey[100], // Add this line for dialog background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Add this line for container background
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedCategory.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedCategory.icon,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Görev Detayları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Title Field
              Text(
                'Başlık',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Görev başlığını girin',
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
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Category Dropdown
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(category.icon),
                          ),
                          SizedBox(width: 12),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value!);
                  },
                ),
              ),
              SizedBox(height: 24),

              // Add Notes Field after the Category Dropdown
              SizedBox(height: 24),
              Text(
                'Notlar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Görev ile ilgili notları girin',
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
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarih',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2025),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null && mounted) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  _selectedDate == null
                                      ? 'Tarih Seç'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => _selectedTime = time);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  _selectedTime == null
                                      ? 'Saat Seç'
                                      : '${_selectedTime!.format(context)}',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Task Status
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: CheckboxListTile(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() => _isCompleted = value!);
                  },
                  title: Text(
                    'Tamamlandı',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Güncelle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      categoryId: _selectedCategoryId,
      dueDate: _selectedDate,
      time: _selectedTime?.format(context) ?? "Tüm gün",
      isCompleted: _isCompleted,
      notes: _notesController.text, // Add this line
    );

    try {
      await ref
          .read(todoProvider.notifier)
          .updateTodo(widget.task.id, updatedTask);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görev güncellenirken bir hata oluştu')),
        );
      }
    }
  }
}
