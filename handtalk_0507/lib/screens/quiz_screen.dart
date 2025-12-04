// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:handtalk/screens/result_screen.dart'; // ResultScreen을 위한 임포트 추가
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

// JSON 파일에서 퀴즈 데이터를 로드하고 선택지를 무작위로 생성하는 함수
Future<List<Map<String, dynamic>>> loadQuizQuestions() async {
  final String jsonString =
      await rootBundle.loadString('assets/quiz_questions.json');
  final List<dynamic> jsonData = json.decode(jsonString);

  final List<String> allWords =
      jsonData.map((e) => e['word'] as String).toList();

  return jsonData.map((q) {
    String correct = q['word'];
    List<String> options = List.from(allWords.where((w) => w != correct))
      ..shuffle();
    options = options.take(3).toList();
    options.add(correct);
    options.shuffle();
    return {
      'videoUrl': q['videoUrl'],
      'options': options,
      'correctAnswerIndex': options.indexOf(correct)
    };
  }).toList();
}

// 퀴즈 화면을 담당하는 StatefulWidget
class QuizScreen extends StatefulWidget {
  final String quizType;

  const QuizScreen({super.key, required this.quizType});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _quizQuestions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _selectedAnswerIndex = -1;
  String _errorMessage = '';

  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  final int _quizLimit = 10; // 퀴즈 문제를 10개로 제한하는 변수

  @override
  void initState() {
    super.initState();
    _loadAndInitializeQuiz();
  }

  Future<void> _loadAndInitializeQuiz() async {
    try {
      final data = await loadQuizQuestions();
      data.shuffle(); // 전체 문제 리스트를 무작위로 섞음

      // 처음 10문제만 사용하도록 리스트를 자름
      final limitedData = data.take(_quizLimit).toList();

      setState(() {
        _quizQuestions = limitedData;
        _isLoading = false;
      });

      if (_quizQuestions.isNotEmpty) {
        _initializeVideo(_quizQuestions[_currentQuestionIndex]['videoUrl']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터 로딩 중 오류가 발생했습니다: $e';
      });
      print('Error loading quiz data: $e');
    }
  }

  // 비디오를 초기화하는 함수
  Future<void> _initializeVideo(String videoUrl) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    _controller.addListener(() {
      setState(() {});
    });

    try {
      await _controller.initialize();
      _controller.setLooping(true);
      await _controller.play();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '비디오를 로드하는 중 오류가 발생했습니다: $e';
      });
      print("Video initialization error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 사용자가 선택한 정답을 확인하고 다음 문제로 넘어가는 함수
  void _checkAnswer(int selectedIndex) {
    if (_selectedAnswerIndex != -1) {
      // 이미 선택했다면 무시
      return;
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    if (selectedIndex == currentQuestion['correctAnswerIndex']) {
      setState(() {
        _score++;
        _errorMessage = '정답입니다!';
      });
    } else {
      setState(() {
        _errorMessage = '오답입니다.';
      });
    }
    setState(() {
      _selectedAnswerIndex = selectedIndex;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex == -1) {
      setState(() {
        _errorMessage = '정답을 선택해주세요.';
      });
      return;
    }

    _controller.dispose();
    _isVideoInitialized = false;

    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = -1;
      _errorMessage = '';
    });

    if (_currentQuestionIndex < _quizQuestions.length) {
      _initializeVideo(_quizQuestions[_currentQuestionIndex]['videoUrl']);
    } else {
      // 모든 문제를 풀었을 경우 결과 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            total: _quizQuestions.length,
            quizType: widget.quizType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_quizQuestions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            '퀴즈 문제를 불러올 수 없습니다.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 수어 퀴즈'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '문제 ${_currentQuestionIndex + 1} / ${_quizQuestions.length}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _isVideoInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              ...List.generate(
                options.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _checkAnswer(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAnswerIndex == index
                          ? (index == currentQuestion['correctAnswerIndex']
                              ? Colors.green
                              : Colors.red)
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(options[index]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('다음 문제', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
