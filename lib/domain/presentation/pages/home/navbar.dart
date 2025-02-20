import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/domain/presentation/pages/ai/ai_assistan_page.dart';
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
    AiAssistantPage(),
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
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
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
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
              _buildNavItem(
                  Icons.smart_toy, "AI Asistan", 2, screenWidth), // Düzeltildi
              _buildNavItem(Icons.bar_chart, "İstatistik", 3, screenWidth),
              _buildNavItem(Icons.person_rounded, "Profil", 4, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, double screenWidth) {
    final isSelected = _currentIndex == index;
    final itemWidth = (screenWidth - 32) / 5;

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
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: isSelected ? 28 : 24,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
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
