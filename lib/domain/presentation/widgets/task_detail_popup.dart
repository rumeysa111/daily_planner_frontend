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
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late String _selectedCategoryId;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.dueDate;
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
        userId: "", // Add this line
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(selectedCategory.icon, style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text('Görev Detayları',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
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
                  setState(() => _selectedCategoryId = value!);
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Text(_selectedDate == null
                          ? 'Tarih Seç'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2025),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.access_time),
                      label: Text(_selectedTime == null
                          ? 'Saat Seç'
                          : '${_selectedTime!.format(context)}'),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() => _isCompleted = value!);
                    },
                  ),
                  Text('Tamamlandı'),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Kaydet'),
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
