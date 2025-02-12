import 'package:flutter/material.dart';
import 'package:mytodo_app/domain/presentation/pages/home/statistics_page.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'profile_page.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomPadding + 12,
          top: 12,
        ),
        height: isSmallScreen ? 65 : 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Ana Sayfa", 0, screenWidth),
              _buildNavItem(
                  Icons.calendar_today_rounded, "Takvim", 1, screenWidth),
              _buildNavItem(Icons.bar_chart, "İstatistik", 2, screenWidth),
              _buildNavItem(Icons.person_rounded, "Profil", 3, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, double screenWidth) {
    final isSelected = _currentIndex == index;
    final itemWidth = (screenWidth - 32) / 4;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _controller.forward(from: 0.0);
      },
      child: Container(
        width: itemWidth,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 12 : 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
                size: isSelected ? 28 : 24,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
