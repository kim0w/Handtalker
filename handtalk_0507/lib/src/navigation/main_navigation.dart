// lib/screens/screens/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:handtalk/screens/screens/home_screen.dart';
import 'package:handtalk/screens/screens/ai_tutor_screen.dart'; // ✅ 전체 퀴즈 플로우 화면
import 'package:handtalk/screens/screens/nomal_quiz_screen.dart';
import 'package:handtalk/screens/screens/course_screen.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MainScreenWithTabs(), // 홈
    AiTutorScreen(), // ✅ AI 퀴즈(문제 로딩 → 녹화 → 업로드/채점)
    CertificateScreen(), // 일반 퀴즈
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI 퀴즈'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '일반 퀴즈'),
        ],
      ),
    );
  }
}
