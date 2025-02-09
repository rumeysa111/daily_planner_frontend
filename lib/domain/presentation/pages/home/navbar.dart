import 'package:flutter/material.dart';
import 'focus_mode_page.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'add_task_page.dart';
import 'profile_page.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    FocusModePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // 📌 Seçili sayfayı göster
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Takvim"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm_add), label: "Odaklan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        selectedItemColor: Colors.blue, // 📌 Seçili olan ikonun rengi
        unselectedItemColor: Colors.grey, // 📌 Seçili olmayan ikonların rengi
        type: BottomNavigationBarType.fixed, // 📌 4 öğe olduğu için sabit tür kullanıyoruz
      ),
    );
  }
}
