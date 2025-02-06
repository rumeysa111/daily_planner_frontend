import 'package:flutter/material.dart';
import 'package:mytodo_app/routes/routes.dart';
import 'package:mytodo_app/theme/colors.dart';
import 'package:mytodo_app/views/onboarding/onboarding_page1.dart';
import 'package:mytodo_app/views/onboarding/onboarding_page2.dart';
import 'package:mytodo_app/views/onboarding/onboarding_page3.dart';
import 'package:mytodo_app/views/onboarding/onboarding_page4.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login); // 📌 Son sayfada Login'e yönlendir
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                OnboardingPage1(),
                OnboardingPage2(),
                OnboardingPage3(),
                OnboardingPage4(),
              ],
            ),
          ),

          // 📌 Sayfa Kontrolleri ve Buton
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: screenWidth * 0.8,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == 0 ? "Başla" : (_currentPage == 3 ? "Tamamla" : "Devam Et"),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
