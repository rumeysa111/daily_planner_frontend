import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/todo_model.dart';
import '../../../../core/navigation/routes.dart';

import '../../viewmodels/todo_viewmodel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/todo_model.dart';
import '../../../../core/navigation/routes.dart';

import '../../viewmodels/todo_viewmodel.dart';

class CalendarPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarVM = ref.watch(calendarProvider.notifier);
    final calendarTasks = ref.watch(calendarProvider);
    final selectedDate = calendarVM.selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: Text("Takvim",
            style: TextStyle(
                color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 📌 TAKVİM BÖLÜMÜ
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                calendarVM.setSelectedDate(selectedDay);
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // 📌 SEÇİLİ GÜNÜN GÖREVLERİ
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTaskList(calendarTasks, selectedDate),
            ),
          ),
        ],
      ),

      // 📌 + GÖREV EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addtask,
            arguments:
                selectedDate, // 📌 Seçili tarihi görev ekleme sayfasına gönder
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 📌 SEÇİLİ GÜNÜN GÖREVLERİNİ GETİREN WIDGET
  Widget _buildTaskList(List<TodoModel> tasks, DateTime selectedDate) {
    // 📌 Seçili tarihe ait görevleri filtrele
    final filteredTasks = tasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, selectedDate);
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          "No tasks for ${DateFormat("dd/MM/yyyy").format(selectedDate)}",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          color: Colors.blue[50],
          child: ListTile(
            title:
                Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text(task.time != null ? "Saat: ${task.time}" : "Tüm gün"),
            trailing: Icon(Icons.check_circle,
                color: task.isCompleted ? Colors.green : Colors.grey),
          ),
        );
      },
    );
  }
}
