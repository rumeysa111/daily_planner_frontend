import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../widgets/task_item.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../home/add_task_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    
    // İlk yüklemede veri getirme işlemini güvenli bir şekilde yap
    Future.microtask(() {
      _loadTasks(_focusedDay);
    });
  }

  // Görev yükleme mantığını tek bir metoda taşıyalım
  void _loadTasks(DateTime date) {
    if (!mounted) return;
    ref.read(calendarProvider.notifier).setSelectedDate(date);
    ref.read(calendarProvider.notifier).fetchTodosByDate(date);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(ref.read(calendarProvider.notifier).selectedDate, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
      });
      _loadTasks(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final isLoading = ref.watch(calendarProvider.notifier).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Takvim',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _focusedDay = now;
              });
              _onDaySelected(now, now);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(_focusedDay),
          SizedBox(height: 8),
          _buildSelectedDateHeader(_focusedDay),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildTaskList(calendarState, ref.read(calendarProvider.notifier)),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, _focusedDay),
    );
  }

  Widget _buildCalendar(DateTime selectedDate) {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: _onDaySelected,
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSelectedDateHeader(DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.event, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TodoModel> tasks, CalendarViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          time: task.time ?? "Belirtilmemiş",
          onComplete: () => _handleTaskCompletion(task),
          onDelete: () => _handleTaskDeletion(task),
        );
      },
    );
  }

  Future<void> _handleTaskCompletion(TodoModel task) async {
    if (!mounted) return;

    try {
      await ref.read(todoProvider.notifier).toggleTaskCompletion(task.id);
      // Task tamamlandıktan sonra calendar view'ı güncelle
      _loadTasks(task.dueDate ?? _focusedDay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görev güncellenirken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> _handleTaskDeletion(TodoModel task) async {
    if (!mounted) return;

    try {
      final success = await ref.read(todoProvider.notifier).deleteTodo(task.id);
      if (success) {
        _loadTasks(task.dueDate ?? _focusedDay);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Görev başarıyla silindi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev silinirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFloatingActionButton(
      BuildContext context, DateTime selectedDate) {
    return FloatingActionButton(
      onPressed: () => _showAddTaskPage(context, selectedDate),
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
    );
  }

  Future<void> _showAddTaskPage(
      BuildContext context, DateTime selectedDate) async {
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(selectedDate: selectedDate),
      ),
    );

    // Sayfa kapandığında ve yeni görev eklendiyse görevleri yenile
    if (mounted && result == true) {
      _loadTasks(selectedDate);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Bu tarihe ait görev bulunamadı',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
