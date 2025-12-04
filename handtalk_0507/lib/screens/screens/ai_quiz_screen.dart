// lib/screens/screens/ai_quiz_screen.dart
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // XFile 사용
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// 채점 대기 화면
/// - 녹화가 끝난 XFile 비디오를 서버로 업로드
/// - "채점 중입니다 잠시만 기다려주세요" 메시지를 보여주며 결과를 대기
/// - 결과를 수신하면 상위로 전달(pop 또는 onDone)
class AiQuizScreen extends StatefulWidget {
  const AiQuizScreen({
    super.key,
    required this.videoFile,                   // 녹화본(XFile)
    required this.word,                        // 서버에서 받은 문제 단어
    required this.category,                    // 서버에서 받은 카테고리(문자열 형태)
    this.endpoint = 'http://13.125.229.164/predict/',
    this.fileFieldName = 'video',              // 서버 파일 필드명
    this.timeout = const Duration(seconds: 60),// ⬅️ 25s → 60s 로 상향
    this.onDone,
    this.mimeType,                             // 필요 시 강제 MIME (예: 'video/mp4')
  });

  final XFile videoFile;
  final String word;
  final String category;

  final String endpoint;
  final String fileFieldName;
  final Duration timeout;
  final void Function(AiQuizResult result)? onDone;

  final String? mimeType;

  @override
  State<AiQuizScreen> createState() => _AiQuizScreenState();
}

class _AiQuizScreenState extends State<AiQuizScreen> {
  bool _isUploading = true;
  String? _errorMessage;
  AiQuizResult? _result;

  @override
  void initState() {
    super.initState();
    // 화면 진입 직후 업로드 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _uploadAndAwait());
  }

  Future<void> _uploadAndAwait() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final res = await _postVideoAndGetResult(
        endpoint: widget.endpoint,
        videoFile: widget.videoFile,
        word: widget.word,
        category: widget.category,
        fileFieldName: widget.fileFieldName,
        timeout: widget.timeout,
        mimeTypeOverride: widget.mimeType,
      );

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _result = res;
      });

      // 상위로 전달
      if (widget.onDone != null) {
        widget.onDone!(res);
      } else {
        Navigator.pop(context, res);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<AiQuizResult> _postVideoAndGetResult({
    required String endpoint,
    required XFile videoFile,
    required String word,
    required String category,
    required String fileFieldName,
    required Duration timeout,
    String? mimeTypeOverride,
  }) async {
    // / 유무 모두 대응
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    final candidates = <Uri>[
      Uri.parse(base),
      Uri.parse('$base/'),
    ];

    final filename = videoFile.name.isNotEmpty ? videoFile.name : 'record.mp4';

    // MIME 추론
    final mime = mimeTypeOverride ?? lookupMimeType(filename) ?? 'application/octet-stream';
    final parts = mime.split('/');
    final mediaType = MediaType(parts.first, parts.length > 1 ? parts[1] : 'octet-stream');

    http.Response? lastResp;
    int? lastStatus;

    for (final uri in candidates) {
      final req = http.MultipartRequest('POST', uri)
        ..fields['word'] = word
        ..fields['category'] = category;

      // 모바일/데스크톱: fromPath 사용, 웹: 바이트로 대체
      if (!kIsWeb && videoFile.path.isNotEmpty) {
        req.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          videoFile.path,
          filename: filename,
          contentType: mediaType,
        ));
      } else {
        final bytes = await videoFile.readAsBytes();
        req.files.add(http.MultipartFile.fromBytes(
          fileFieldName,
          bytes,
          filename: filename,
          contentType: mediaType,
        ));
      }

      final streamed = await req.send().timeout(timeout);
      final resp = await http.Response.fromStream(streamed);
      lastResp = resp;
      lastStatus = resp.statusCode;

      if (resp.statusCode == 200) break; // 성공 시 종료
    }

    if (lastResp == null) {
      throw Exception('서버 응답이 없습니다.');
    }
    if (lastStatus != 200) {
      final body = utf8.decode(lastResp.bodyBytes);
      throw Exception('업로드 실패 ${lastResp.statusCode}: $body');
    }

    return _parseResult(lastResp);
  }

  AiQuizResult _parseResult(http.Response resp) {
    final text = utf8.decode(resp.bodyBytes).trim();
    if (text.isEmpty) {
      return AiQuizResult(success: true, prediction: '', raw: null);
    }

    // JSON 파싱 시도
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        // ⬇️ 서버가 `{"result":"정답"}` 형태를 보내므로 'result'를 최우선
        final dynamic r = (decoded['result'] ??
            decoded['prediction'] ??
            decoded['recognized'] ??
            decoded['word']);

        String prediction;
        if (r is bool) {
          prediction = r ? '정답' : '오답';
        } else {
          prediction = (r ?? '').toString();
        }
        return AiQuizResult(success: true, prediction: prediction, raw: decoded);
      } else if (decoded is List) {
        final first = decoded.isNotEmpty ? decoded.first.toString() : '';
        return AiQuizResult(success: true, prediction: first, raw: decoded);
      } else {
        return AiQuizResult(success: true, prediction: decoded.toString(), raw: decoded);
      }
    } catch (_) {
      // JSON 아님 → 평문 그대로
      return AiQuizResult(success: true, prediction: text, raw: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isUploading
        ? '채점 중...' // 상단 제목
        : (_errorMessage != null ? '업로드 실패' : '채점 완료');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isUploading
                ? _buildLoading()
                : (_errorMessage != null ? _buildError() : _buildDone()),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          '채점 중입니다 잠시만 기다려주세요', // 표기 통일(맞춤법: 채점)
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 12),
        const Text('업로드 또는 채점 도중 오류가 발생했어요.'),
        const SizedBox(height: 8),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: 160,
          child: ElevatedButton(
            onPressed: _uploadAndAwait,
            child: const Text('다시 시도'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('취소하고 돌아가기'),
        ),
      ],
    );
  }

  Widget _buildDone() {
    final res = _result!;
    return Column(
      key: const ValueKey('done'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 56, color: Colors.green),
        const SizedBox(height: 12),
        const Text('채점이 완료되었어요!'),
        const SizedBox(height: 8),
        if (res.prediction.isNotEmpty)
          Text(
            '서버 응측: ${res.prediction}', // 결과 문자열(예: "정답"/"오답")
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 18),
        SizedBox(
          width: 160,
          child: ElevatedButton(
            onPressed: () {
              if (widget.onDone != null && _result != null) {
                widget.onDone!(res);
              } else {
                Navigator.pop(context, res);
              }
            },
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}

/// 업로드/채점 결과 모델 (정확도 없이 prediction만)
class AiQuizResult {
  AiQuizResult({
    required this.success,
    required this.prediction,
    this.raw,
  });

  final bool success;
  final String prediction; // 서버가 보낸 결과 문자열(예: "정답")
  final Object? raw;       // 원문 응답(디버깅용)
}
