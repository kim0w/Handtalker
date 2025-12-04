import 'package:flutter/material.dart';
import 'package:handtalk/screens/screens/nomal_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences를 위한 임포트
import 'dart:convert'; // JSON 인코딩/디코딩을 위한 임포트

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String quizType;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.quizType,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 퀴즈 점수를 저장합니다.
    saveQuizScore(widget.score, widget.total, widget.quizType);
  }

  // SharedPreferences에 퀴즈 점수를 저장하는 함수
  Future<void> saveQuizScore(int score, int total, String quizType) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존 기록 가져오기
    String? recordsJson = prefs.getString('quiz_records');
    List records = recordsJson != null ? jsonDecode(recordsJson) : [];

    // 현재 기록을 리스트의 맨 앞에 추가
    records.insert(0, {
      'score': score,
      'total': total,
      'type': quizType,
      'date': DateTime.now().toIso8601String(), // 날짜 저장
    });

    // SharedPreferences에 저장
    await prefs.setString('quiz_records', jsonEncode(records));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 결과')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '퀴즈 완료!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '점수: ${widget.score} / ${widget.total}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificateScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 파란색 배경
                  foregroundColor: Colors.white, // 흰색 글씨
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('확인', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
