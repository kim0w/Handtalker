import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:handtalk/screens/screens/course_screen.dart';
import 'package:handtalk/widgets/home_screen_widgets.dart';

class MainScreenWithTabs extends StatefulWidget {
  const MainScreenWithTabs({super.key});

  @override
  State<MainScreenWithTabs> createState() => _MainScreenWithTabsState();
}

class _MainScreenWithTabsState extends State<MainScreenWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '홈'),
            Tab(text: '코스'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreen(),
          CourseScreen(),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 상단 우측 '>' 버튼 및 이동 기능 제거됨
            const SizedBox(height: 16),
            const TodayLessonCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _launchURL('https://cbtbank.kr/exam/eu11000100');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  '한국수어교원자격 검정시험',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
