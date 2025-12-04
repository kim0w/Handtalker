import 'package:flutter/material.dart';

// 퀴즈 결과 데이터를 담을 클래스
class QuizResult {
  final String quizWord; // 출제된 단어
  final String recognizedWord; // 서버가 인식한 단어


  QuizResult({
    required this.quizWord,
    required this.recognizedWord,

  });
}

class QuizResultScreen extends StatelessWidget {
  final List<QuizResult> results;

  const QuizResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈 결과'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '총 10문제의 퀴즈가 완료되었습니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '각 수어 동작에 대한 AI의 채점 결과입니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  // 정답 여부 판단
                  final bool isCorrect =
                      result.quizWord == result.recognizedWord;
                  final IconData icon =
                      isCorrect ? Icons.check_circle : Icons.cancel;
                  final Color iconColor = isCorrect ? Colors.green : Colors.red;
                  final String recognitionResultText = isCorrect
                      ? '정확한 동작입니다!'
                      : 'AI가 "${result.recognizedWord}"으로 인식했습니다.';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(icon, color: iconColor, size: 40),
                      title: Text(
                        '문제 ${index + 1}: "${result.quizWord}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            recognitionResultText,
                            style: TextStyle(
                              fontSize: 16,
                              color: isCorrect
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 결과 화면 닫고 이전 화면으로 돌아가기 (AiTutorScreen)
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  '다시 퀴즈 시작하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
