import 'package:flutter/material.dart';
import 'package:handtalk/screens/quiz_screen.dart';
import 'package:handtalk/screens/result_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences를 위한 임포트
import 'dart:convert'; // JSON 인코딩/디코딩을 위한 임포트

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  // 퀴즈 타입을 '단어'로 고정합니다.
  final String _quizType = '단어';

  // FutureBuilder에서 사용할 퀴즈 기록을 불러오는 함수
  Future<List<Map<String, dynamic>>> loadQuizRecords() async {
    final prefs = await SharedPreferences.getInstance();
    String? recordsJson = prefs.getString('quiz_records');
    if (recordsJson == null) return [];

    List records = jsonDecode(recordsJson);
    return records.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어 퀴즈')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '단어 퀴즈',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(quizType: _quizType),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('퀴즈 시작', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
              const Text(
                '나의 퀴즈 기록',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // FutureBuilder를 사용하여 기록을 비동기적으로 불러와 표시
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadQuizRecords(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('오류 발생: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('아직 퀴즈 기록이 없습니다.'));
                    } else {
                      final records = snapshot.data!;
                      return ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          // 저장된 날짜 문자열을 DateTime 객체로 변환
                          final date = DateTime.parse(record['date']);
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Icon(
                                record['type'] == '단어'
                                    ? Icons.font_download
                                    : Icons.article,
                                color: Colors.blue,
                              ),
                              title:
                                  Text('${record['type']} 퀴즈 - $formattedDate'),
                              subtitle: Text(
                                  '점수: ${record['score']} / ${record['total']}'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('${record['type']} 퀴즈 결과'),
                                    content: Text(
                                      '날짜: $formattedDate\n점수: ${record['score']} / ${record['total']}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('닫기'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
