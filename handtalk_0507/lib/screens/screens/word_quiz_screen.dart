import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;

  const CustomIconButton({
    required this.onPressed,
    required this.iconData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(iconData),
      iconSize: 30.0,
      color: Colors.white,
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String quizType; // 'word' or 'sentence'
  const QuizScreen({super.key, required this.quizType});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isPremium = false;
  bool _isLoading = true;
  String? _errorMessage;

  late List<Map<String, dynamic>> _quizQuestions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchQuizQuestions();
  }

  Future<void> _fetchQuizQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // API 엔드포인트 설정
      final apiUrl = widget.quizType == 'word'
          ? 'https://your-api.com/api/word-quiz'
          : 'https://your-api.com/api/sentence-quiz';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _quizQuestions = data
              .map((item) => {
                    'question': item['question'],
                    'options': item['options'],
                    'correctAnswer': item['correctAnswer'],
                    'imageUrl': item['imageUrl'],
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quiz questions');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '퀴즈를 불러오는데 실패했습니다. 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });
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

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('수어 퀴즈')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchQuizQuestions,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('수어 퀴즈'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuizContent(),
          _buildChallengeContent(),
          _buildRankingContent(),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_currentQuestionIndex >= _quizQuestions.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('퀴즈 완료! 점수: $_score/${_quizQuestions.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _score = 0;
                });
              },
              child: const Text('다시 시작'),
            ),
          ],
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _quizQuestions.length,
          ),
          const SizedBox(height: 20),
          // 이미지 표시
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(currentQuestion['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            currentQuestion['question'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            currentQuestion['options'].length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  _checkAnswer(index);
                },
                child: Text(currentQuestion['options'][index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _buildRankingContent() {
    return ListView.builder(
      itemCount: 10, // 예시 데이터
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text('${index + 1}'),
          title: Text('사용자 ${index + 1}'),
          trailing: Text('${1000 - index * 100}점'),
        );
      },
    );
  }

  void _checkAnswer(int selectedIndex) {
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    if (selectedIndex == currentQuestion['correctAnswer']) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _showPremiumDialog() {
    // Remove the entire dialog implementation
  }
}

class WordQuizScreen extends StatefulWidget {
  const WordQuizScreen({super.key});

  @override
  State<WordQuizScreen> createState() => _WordQuizScreenState();
}

class _WordQuizScreenState extends State<WordQuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  late List<Map<String, dynamic>> _quizQuestions;
  bool _showControls = false;
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchQuizQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuizQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // API 엔드포인트 설정
      final apiUrl = 'https://your-api.com/api/word-quiz';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _quizQuestions = data
              .map((item) => {
                    'question': item['question'],
                    'options': item['options'],
                    'correctAnswer': item['correctAnswer'],
                    'imageUrl': item['imageUrl'],
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quiz questions');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '퀴즈를 불러오는데 실패했습니다. 다시 시도해주세요.';
        _isLoading = false;
      });
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

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('수어 퀴즈')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchQuizQuestions,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('수어 퀴즈'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuizContent(),
          _buildChallengeContent(),
          _buildRankingContent(),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_currentQuestionIndex >= _quizQuestions.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('퀴즈 완료! 점수: $_score/${_quizQuestions.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _score = 0;
                });
              },
              child: const Text('다시 시작'),
            ),
          ],
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _quizQuestions.length,
          ),
          const SizedBox(height: 20),
          // 이미지 표시
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(currentQuestion['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            currentQuestion['question'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            currentQuestion['options'].length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  _checkAnswer(index);
                },
                child: Text(currentQuestion['options'][index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _buildRankingContent() {
    return ListView.builder(
      itemCount: 10, // 예시 데이터
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text('${index + 1}'),
          title: Text('사용자 ${index + 1}'),
          trailing: Text('${1000 - index * 100}점'),
        );
      },
    );
  }

  void _checkAnswer(int selectedIndex) {
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    if (selectedIndex == currentQuestion['correctAnswer']) {
      setState(() {
        _score++;
      });
    }
    setState(() {
      _currentQuestionIndex++;
    });
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      backgroundImage: AssetImage("assets/images/default_profile.png"),
      radius: 30,
    );
  }
}
