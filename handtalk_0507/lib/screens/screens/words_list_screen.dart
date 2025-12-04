import 'package:flutter/material.dart';
import 'package:handtalk/screens/screens/sign_language_webview.dart';

class QuizWord {
  final int originalIndex; // 원래 인덱스
  final String word;

  QuizWord({required this.originalIndex, required this.word});
}

class WordsListScreen extends StatefulWidget {
  final List<String> allQuizWords;

  const WordsListScreen({super.key, required this.allQuizWords});

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  late List<QuizWord> _sortedWords;
  late List<QuizWord> _filteredWords;
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List<String>> _relatedWords = {
    '자동차': ['승용차', '트럭', '버스'],
    '차': ['승용차', '트럭', '버스'],
    '사람': ['남자', '여자', '어린이', '어른'],
  };

  @override
  void initState() {
    super.initState();
    _initializeWords();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeWords() {
    _sortedWords = widget.allQuizWords.asMap().entries.map((e) {
      return QuizWord(originalIndex: e.key + 1, word: e.value);
    }).toList()
      ..sort((a, b) => a.word.compareTo(b.word));

    _filteredWords = List.from(_sortedWords);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredWords = List.from(_sortedWords);
      } else {
        final relatedList = _relatedWords[query] ?? [];
        final searchTerms =
            [query, ...relatedList].map((term) => term.toLowerCase()).toSet();

        _filteredWords = _sortedWords.where((item) {
          return searchTerms
              .any((term) => item.word.toLowerCase().contains(term));
        }).toList();
      }
    });
  }

  void _onWordTapped(String word) {
    const String baseUrl =
        'https://sldict.korean.go.kr/front/search/searchAllList.do';
    final encodedWord = Uri.encodeComponent(word);
    final String url =
        '$baseUrl?searchKeyword=$encodedWord&searchCondition=all';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignLanguageWebView(title: word, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수어 단어 목록'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '단어를 검색하세요...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _filteredWords.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _filteredWords.length,
                    itemBuilder: (context, index) {
                      final item = _filteredWords[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              '${item.originalIndex}', // 원래 번호 유지
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item.word),
                          onTap: () => _onWordTapped(item.word),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
