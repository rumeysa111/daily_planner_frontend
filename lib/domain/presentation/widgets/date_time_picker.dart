import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay?) onTimeSelected;

  const DateTimePicker({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tarih ve Saat", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) onDateSelected(pickedDate);
                },
                icon: Icon(Icons.calendar_today, color: Colors.orange),
                label: Text(selectedDate != null ? DateFormat("dd/MM/yyyy").format(selectedDate!) : "Tarih Seç"),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  onTimeSelected(pickedTime);
                },
                icon: Icon(Icons.access_time, color: Colors.red),
                label: Text(selectedTime != null ? selectedTime!.format(context) : "Saat Seç"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
