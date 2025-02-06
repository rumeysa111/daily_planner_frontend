import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../routes/routes.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // 📌 Örnek görevler (Bunu backend ile değiştireceğiz!)
  final Map<DateTime, List<String>> _tasks = {
    DateTime(2025, 2, 16): ["Finish Report - 9:45PM", "Water the plants - 10:00AM"],
    DateTime(2025, 2, 17): ["Team Meeting - 2:00PM"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: _buildTaskList(),
            ),
          ),
        ],
      ),

      // 📌 + GÖREV EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        onPressed: () {
Navigator.pushNamed(context, AppRoutes.addtask);        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 📌 SEÇİLİ GÜNÜN GÖREVLERİNİ GÖSTEREN WIDGET
  Widget _buildTaskList() {
    DateTime today = _selectedDay ?? _focusedDay;
    List<String> tasks = _tasks[today] ?? [];

    if (tasks.isEmpty) {
      return Center(
        child: Text(
          "No tasks for ${DateFormat("dd/MM/yyyy").format(today)}",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          color: Colors.blue[50],
          child: ListTile(
            title: Text(tasks[index], style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  _tasks[today]?.removeAt(index);
                });
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ),
        );
      },
    );
  }
}
