// lib/screens/screens/video_recorder_widget.dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:handtalk/screens/screens/ai_quiz_screen.dart'; // 업로드/채점 대기 화면 (XFile 기반)

/// 비디오 녹화 위젯
/// - 카메라 초기화/프리뷰/녹화 시작·중지
/// - 녹화 종료 시 AiQuizScreen으로 이동하여 업로드/채점 수행
/// - 서버에는 word, category(문자열)도 함께 전달(화면에는 word만 노출)
class VideoRecorderWidget extends StatefulWidget {
  const VideoRecorderWidget({
    super.key,
    required this.onCameraStatusChanged,
    required this.onRecordingComplete,
    this.quizWord,
    this.category = '2', // 서버 업로드용 카테고리(문자열). 세션에서 전달받으면 override됨
    this.enableAudio = false,
  });

  /// 카메라 활성/비활성 상태 콜백
  final void Function(bool active) onCameraStatusChanged;

  /// 채점 완료 후 서버 예측 결과(문자열)를 상위로 전달
  final void Function(String prediction) onRecordingComplete;

  /// 현재 문제 단어(화면 표기 + 업로드 전송)
  final String? quizWord;

  /// 현재 문제 카테고리(업로드 전송만, 화면 비표시). 문자열 형태로 유지
  final String category;

  /// 오디오 녹음 여부(기본 false)
  final bool enableAudio;

  @override
  State<VideoRecorderWidget> createState() => VideoRecorderWidgetState();
}

class VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  CameraDescription? _selected;

  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isInitializingNow = false;
  bool _isPushingQuizScreen = false;

  String? _lastError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _lastError = null;
    setState(() => _isInitializingNow = true);

    try {
      // 웹은 permission_handler를 건너뛰는 편
      if (!kIsWeb) {
        final camStatus = await Permission.camera.request();
        if (!camStatus.isGranted) {
          widget.onCameraStatusChanged(false);
          _showSnack('카메라 권한이 필요합니다.', error: true);
          setState(() => _isInitializingNow = false);
          return;
        }
        if (widget.enableAudio) {
          await Permission.microphone.request();
        }
      }

      await _loadCameras();
      if (_cameras.isEmpty) {
        widget.onCameraStatusChanged(false);
        _showSnack('사용 가능한 카메라가 없습니다.', error: true);
        setState(() => _isInitializingNow = false);
        return;
      }

      _selected = _preferFrontOrFirst(_cameras);
      await _initializeCamera(_selected!);

      setState(() => _isInitializingNow = false);
    } catch (e) {
      widget.onCameraStatusChanged(false);
      _showSnack('초기화 오류: $e', error: true);
      setState(() => _isInitializingNow = false);
    }
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      _cameras = [];
      _lastError = 'availableCameras 실패: $e';
    }
    setState(() {});
  }

  CameraDescription _preferFrontOrFirst(List<CameraDescription> cams) {
    final i = cams.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    return i >= 0 ? cams[i] : cams.first;
  }

  Future<void> _initializeCamera(CameraDescription cam) async {
    try {
      _controller?.dispose();
      _controller = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: widget.enableAudio,
      );
      await _controller!.initialize();
      try {
        await _controller!.prepareForVideoRecording();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _lastError = null;
      });
      widget.onCameraStatusChanged(true);
    } on CameraException catch (e) {
      widget.onCameraStatusChanged(false);
      _lastError = 'CameraException: ${e.code}';
      setState(() => _isInitialized = false);
      _showSnack('카메라 초기화 오류: ${e.code}', error: true);
    } catch (e) {
      widget.onCameraStatusChanged(false);
      _lastError = 'InitError: $e';
      setState(() => _isInitialized = false);
      _showSnack('카메라 초기화 오류: $e', error: true);
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_isInitialized || _controller == null || _isRecording) return;
    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } on CameraException catch (e) {
      _showSnack('녹화 시작 오류: ${e.code}', error: true);
    } catch (e) {
      _showSnack('녹화 시작 오류: $e', error: true);
    }
  }

  Future<void> _stopVideoRecordingAndPushAiQuiz() async {
    if (!_isRecording || _controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      // 필수 업로드 파라미터
      final word = widget.quizWord ?? 'unknown';
      final category = widget.category; // 문자열 유지

      if (_isPushingQuizScreen) return;
      _isPushingQuizScreen = true;

      // 업로드/채점 대기 화면으로 이동
      final result = await Navigator.push<AiQuizResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => AiQuizScreen(
            videoFile: videoFile,
            word: word,
            category: category,
          ),
        ),
      );

      _isPushingQuizScreen = false;

      if (result == null) return; // 사용자가 취소하거나 실패 시
      // 예측 결과를 상위로 전달(빈 문자열이면 원 단어로 대체)
      widget.onRecordingComplete(
        result.prediction.isNotEmpty ? result.prediction : word,
      );
    } on CameraException catch (e) {
      _showSnack('녹화 중지 오류: ${e.code}', error: true);
    } catch (e) {
      _showSnack('녹화 중지 오류: $e', error: true);
    }
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            _isInitializingNow
                ? '카메라 초기화 중...'
                : (_lastError != null ? '실패: $_lastError' : '카메라가 준비되지 않았습니다.'),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final previewSize = _controller!.value.previewSize;
    // 회전 보정: CameraPreview는 가로/세로가 뒤바뀌는 경우가 있어 width/height 스와핑
    final w = previewSize?.height ?? 1280;
    final h = previewSize?.width ?? 720;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 프리뷰
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: w,
                height: h,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        ),
        // 하단 녹화 버튼
        Positioned(
          bottom: 20,
          child: ElevatedButton.icon(
            onPressed: _isPushingQuizScreen
                ? null
                : () {
              if (_isRecording) {
                _stopVideoRecordingAndPushAiQuiz();
              } else {
                _startVideoRecording();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
            label: Text(
              _isRecording ? '녹화 중지' : '녹화 시작',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
