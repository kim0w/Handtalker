// lib/screens/screens/ai_tutor_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:handtalk/screens/screens/video_recorder_widget.dart';
import 'package:handtalk/screens/screens/quiz_result_screen.dart';
import 'package:handtalk/screens/screens/words_list_screen.dart';

/// 서버에서 문제(단어) 목록을 받아오는 엔드포인트
const String _quizEndpoint = 'http://13.125.229.164/quiz_ai/';

/// 🔹 기본(로컬) 단어 리스트: 서버에서 문제를 받기 전까지 보여줄 목록
const List<String> _defaultWordList = [
  '가능','가다','가족','감사','강','개','고맙다','고양이','공부','공원','괜찮다','귀엽다','끝나다','나',
  '낮','내일','노래','놀이','누구','당신','도서관','돈','먹다','미국','미소','미안하다','밤','반갑다',
  '반성','버스','범죄','보다','부족하다','비','사랑하다','선거','선물','선생님','선풍기','소나무','수입',
  '시간','시작하다','싫다','신발','실습','아름답다','아프다','안녕하다','없다','오늘','운동하다','운전',
  '울다','우산','이름','이어폰','있다','전화하다','지금','지하철','지출','집','승용차','책','친구','커피',
  '컴퓨터','펜','필요하다','학교','학생','화장실','휴대전화','훌륭하다',
];

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  // 카메라 & 진행 상태
  bool _isCameraActive = false;
  bool _isFetching = false; // 문제 로딩 중
  bool _isQuizRunning = false;

  // 레코더 제어용
  final GlobalKey<VideoRecorderWidgetState> _recorderKey = GlobalKey();

  // 문제/진행
  final List<_QuizItem> _quizItems = [];
  int _currentIndex = 0;

  // 결과 누적
  final List<QuizResult> _results = [];

  String get _displayedWord =>
      (_quizItems.isNotEmpty && _currentIndex < _quizItems.length)
          ? _quizItems[_currentIndex].word
          : '';

  // ===== 서버에서 문제 5개 로딩 =====
  Future<void> _loadQuestions() async {
    setState(() {
      _isFetching = true;
      _isQuizRunning = false;
      _quizItems.clear();
      _currentIndex = 0;
      _results.clear();
    });

    try {
      final resp = await http
          .get(Uri.parse(_quizEndpoint))
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final body = utf8.decode(resp.bodyBytes);
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      // 서버 예시:
      // { "1": {"category": 5, "word": "없다"}, ... "5": {...} }
      final keys = decoded.keys.toList()
        ..sort((a, b) {
          final ai = int.tryParse(a) ?? 0;
          final bi = int.tryParse(b) ?? 0;
          return ai.compareTo(bi);
        });

      final items = <_QuizItem>[];
      for (final k in keys) {
        final v = decoded[k];
        if (v is Map<String, dynamic>) {
          final w = (v['word'] ?? '').toString().trim();
          final c = v['category'];
          final catStr = (c == null) ? null : c.toString();
          if (w.isNotEmpty && catStr != null) {
            items.add(_QuizItem(word: w, category: catStr));
          }
        }
      }

      if (items.length < 5) {
        throw Exception('문항이 부족합니다(${items.length}/5).');
      }

      // 항상 5개만 사용 (서버가 5개 초과를 줄 수도 있으니 앞 5개 사용)
      final picked = items.take(5).toList();

      if (!mounted) return;
      setState(() {
        _quizItems.addAll(picked);
        _currentIndex = 0;
        _isQuizRunning = true;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _isQuizRunning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('문제를 불러오지 못했어요: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ===== 시작/종료 토글 =====
  Future<void> _toggleQuiz() async {
    if (_isCameraActive) {
      setState(() {
        _isCameraActive = false;
        _isQuizRunning = false;
        _quizItems.clear();
        _currentIndex = 0;
        _results.clear();
      });
    } else {
      setState(() {
        _isCameraActive = true;
      });
      await _loadQuestions();
    }
  }

  // ===== 채점 완료 콜백: prediction 받아서 다음 문제로 진행 =====
  void _onRecordingComplete(String prediction) {
    if (!mounted || !_isQuizRunning || _quizItems.isEmpty) return;

    final item = _quizItems[_currentIndex];

    _results.add(QuizResult(
      quizWord: item.word,
      recognizedWord: prediction,
    ));

    setState(() {
      _currentIndex++;
      if (_currentIndex >= _quizItems.length) {
        _isQuizRunning = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(results: _results),
          ),
        );
      }
    });
  }

  // 🔹 단어 리스트 열기
  // - 퀴즈 시작 전: 기본 단어 전체(_defaultWordList)
  // - 퀴즈 시작 후(세션 중): 이번 세션 5개만
  void _openWordsList() {
    final List<String> words =
    (!_isQuizRunning || _quizItems.isEmpty)
        ? _defaultWordList
        : _quizItems.map((e) => e.word).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordsListScreen(allQuizWords: words),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraAreaHeight = MediaQuery.of(context).size.height * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 수어 인식'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: cameraAreaHeight,
                child: _isCameraActive
                    ? Stack(
                  children: [
                    VideoRecorderWidget(
                      key: _recorderKey,
                      onCameraStatusChanged: (active) {
                        setState(() => _isCameraActive = active);
                      },
                      onRecordingComplete: _onRecordingComplete,
                      // 화면에는 word만 표시하지만 서버 업로드를 위해 category도 전달
                      quizWord: _isQuizRunning && _quizItems.isNotEmpty
                          ? _quizItems[_currentIndex].word
                          : null,
                      category: _isQuizRunning && _quizItems.isNotEmpty
                          ? _quizItems[_currentIndex].category // 문자열
                          : '0',
                    ),
                    // 상단 문제 배너 (word만 노출)
                    if (_isQuizRunning &&
                        _quizItems.isNotEmpty &&
                        _currentIndex < _quizItems.length)
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentIndex + 1}/${_quizItems.length}번째 단어',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _displayedWord,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // 문제 로딩 중 오버레이
                    if (_isFetching)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'AI 수어 퀴즈',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '아래 "퀴즈 시작" 버튼을 눌러 수어 퀴즈를 시작하세요.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 시작/종료 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _toggleQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCameraActive ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _isCameraActive ? '퀴즈 종료' : '퀴즈 시작',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 단어 리스트 버튼
              // - 퀴즈 시작 전: 활성화(기본 전체 리스트)
              // - 퀴즈 시작 후: 비활성화
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isQuizRunning ? null : _openWordsList,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey[300];
                      }
                      return Colors.grey[400];
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.white70;
                      }
                      return Colors.white;
                    }),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    elevation: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.disabled) ? 0 : 5,
                    ),
                  ),
                  child: const Text(
                    '단어 리스트',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 사용법
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용법',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      '• "퀴즈 시작"을 누르면 서버에서 5개의 문제를 불러옵니다.\n'
                          '• 상단 단어를 보고 수어 동작을 취한 뒤 하단 버튼으로 “녹화 시작/중지”하세요.\n'
                          '• 녹화가 끝나면 영상과 단어/카테고리가 서버로 전송되고, 응답 예측값으로 다음 문제로 이동합니다.\n'
                          '• 5문제를 완료하면 결과 화면으로 이동합니다.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// 내부용 문제 모델 (카테고리는 보관만 하고 화면에는 표시하지 않음)
class _QuizItem {
  final String word;
  final String category; // 업로드용(문자열 유지)
  _QuizItem({required this.word, required this.category});
}
