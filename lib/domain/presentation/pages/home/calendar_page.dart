import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import
import 'package:table_calendar/table_calendar.dart';
import '../../../../data/models/todo_model.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../widgets/task_item.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../home/add_task_page.dart';
import '../../widgets/custom_app_bar.dart';

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
    // Initialize locale data
    initializeDateFormatting('tr_TR', null).then((_) {
      if (mounted) {
        setState(() {
          _focusedDay = DateTime.now();
        });
      }
    });

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
    // Geçmiş tarihleri kontrol et
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geçmiş tarihlere görev eklenemez!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isSameDay(
        ref.read(calendarProvider.notifier).selectedDate, selectedDay)) {
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
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Takvim",
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: Colors.blue),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
              });
              _loadTasks(DateTime.now());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.01,
              ),
              elevation: 2,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                child: _buildCalendar(_focusedDay),
              ),
            ),
            _buildSelectedDateHeader(_focusedDay),
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : _buildTaskList(
                      calendarState, ref.read(calendarProvider.notifier)),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskPage(context, _focusedDay),
          label: Text(
            'Görev Ekle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          icon: Icon(Icons.add,
              color: Colors.white, size: isSmallScreen ? 20 : 24),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Görevler yükleniyor...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(DateTime selectedDate) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onDaySelected: _onDaySelected,
      enabledDayPredicate: (day) {
        return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: isSmallScreen ? 12 : 14,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.red,
          fontSize: isSmallScreen ? 12 : 14,
        ),
        outsideTextStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: isSmallScreen ? 12 : 14,
        ),
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
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: !isSmallScreen,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.blue,
          fontSize: isSmallScreen ? 12 : 14,
        ),
        titleTextStyle: TextStyle(
          fontSize: isSmallScreen ? 15 : 17,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          size: isSmallScreen ? 20 : 24,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          size: isSmallScreen ? 20 : 24,
        ),
      ),
      availableGestures: AvailableGestures.all,
      sixWeekMonthsEnforced: true,
      shouldFillViewport: false,
    );
  }

  Widget _buildSelectedDateHeader(DateTime selectedDate) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final now = DateTime.now();
    String dateText;

    if (isSameDay(selectedDate, now)) {
      dateText = 'Bugün';
    } else if (isSameDay(selectedDate, now.add(Duration(days: 1)))) {
      dateText = 'Yarın';
    } else if (isSameDay(selectedDate, now.subtract(Duration(days: 1)))) {
      dateText = 'Dün';
    } else {
      try {
        dateText = DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate);
      } catch (e) {
        // Fallback to default format if locale fails
        dateText = DateFormat('d MMMM yyyy').format(selectedDate);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event,
              color: Colors.blue,
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
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

    return Expanded(
      // Add this wrapper
      child: ListView.builder(
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
      ),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Expanded(
      // Add this wrapper
      child: Container(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: isSmallScreen ? 36 : 48,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Bu tarihte görev bulunmuyor',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Yeni görev eklemek için + butonuna tıklayın',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
