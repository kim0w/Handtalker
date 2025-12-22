# HandTalker - AI 기반 한국수어 학습 플랫폼

> LSTM 모델을 활용한 실시간 수어 인식 및 인터랙티브 학습 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.4.1+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4.1+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 목차
- [프로젝트 개요](#프로젝트-개요)
- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [시스템 구조](#시스템-구조)
- [설치 및 실행](#설치-및-실행)
- [프로젝트 구조](#프로젝트-구조)
- [스크린샷](#스크린샷)

---

## 프로젝트 개요

**HandTalker**는 한국수어 학습의 접근성을 높이기 위해 개발된 AI 기반 모바일 학습 플랫폼입니다. 딥러닝 기술(LSTM)을 활용하여 사용자의 수어 동작을 실시간으로 인식하고 피드백을 제공하며, 영상 기반 퀴즈와 체계적인 코스 학습을 통해 효과적인 수어 학습 환경을 제공합니다.

### 대상 사용자
- 수어를 처음 배우는 초보자
- 한국수어 단어를 반복 학습하고 싶은 학습자
- 수어 교육 보조 도구가 필요한 교육자
- 수어 인식 AI 기술을 연구하는 개발자

### 프로젝트 목표
- 누구나 쉽게 접근할 수 있는 수어 학습 도구 제공
- AI 기반 실시간 피드백으로 학습 효율 극대화
- 게임화된 퀴즈 시스템으로 학습 동기 부여
- 체계적인 진도 관리 및 학습 기록 추적

---

## 주요 기능

### 1. AI 수어 인식 튜터 (LSTM 기반)
- 사용자의 수어 동작을 카메라로 촬영하여 AI 서버에 전송
- **LSTM(Long Short-Term Memory) 모델**을 사용한 동작 시퀀스 분석
- 실시간으로 정확도를 판단하고 즉각적인 피드백 제공
- 96개의 기본 한국수어 단어 인식 지원

### 2. 영상 기반 퀴즈 학습
- 한국수어사전 공식 영상(WebM)을 활용한 객관식 퀴즈
- 96개의 수어 단어 데이터베이스 (`quiz_questions.json`)
- 매 퀴즈마다 보기 순서 자동 랜덤 셔플
- 점수 및 학습 날짜 자동 저장 (SharedPreferences)

### 3. 체계적인 코스 학습
- **일상생활 수어**: 인간, 삶, 식생활, 의생활, 주생활, 사회생활, 경제생활, 교육 등
- **전문 수어**: 정치, 법률, 경제, 사회, 문화, 스포츠 등
- 한국수어사전 웹뷰 연동으로 카테고리별 심화 학습 지원

### 4. 학습 기록 관리
- 퀴즈 점수 및 날짜를 JSON 형식으로 저장 (ISO 8601)
- 학습 기록 리스트 조회 및 진도 추적
- 전체 기록 초기화 기능

### 5. 단어 목록 및 영상 학습
- 96개 수어 단어 목록 제공
- 각 단어별 영상 재생 및 반복 학습 지원

---

## 기술 스택

### Frontend (Mobile)
- **Flutter 3.4.1+** - 크로스 플랫폼 모바일 앱 개발
- **Dart** - Flutter 개발 언어
- **video_player** - 수어 영상 재생
- **chewie** - 비디오 플레이어 UI
- **camera** - 수어 동작 촬영
- **webview_flutter** - 한국수어사전 웹뷰 연동
- **http** - AI 서버 통신
- **shared_preferences** - 로컬 데이터 저장

### Backend (AI Server)
- **LSTM (Long Short-Term Memory)** - 수어 동작 시퀀스 인식
- **Deep Learning Model** - 수어 동작 분류 및 예측
- **REST API** - Flutter 앱과 서버 간 통신
  - `POST /predict/` - 수어 동작 비디오 업로드 및 인식
  - `GET /quiz_ai/` - AI 퀴즈 문제 요청

### Data
- **JSON** - 퀴즈 문제 데이터 관리 (`quiz_questions.json`)
- **한국수어사전 API** - 공식 수어 영상 제공

---

## 시스템 구조

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Flutter App    │────────▶│   AI Server      │────────▶│  LSTM Model     │
│  (Mobile)       │◀────────│  (REST API)      │◀────────│  (TensorFlow)   │
└─────────────────┘         └──────────────────┘         └─────────────────┘
       │                            │
       │                            │
       ▼                            ▼
┌─────────────────┐         ┌──────────────────┐
│ SharedPreferences│         │ 한국수어사전 API │
│ (Local Storage) │         │ (Video Source)   │
└─────────────────┘         └──────────────────┘
```

### AI 수어 인식 프로세스
1. 사용자가 카메라로 수어 동작 촬영 (5초)
2. 촬영된 비디오를 AI 서버로 전송 (`POST /predict/`)
3. 서버에서 LSTM 모델을 사용하여 동작 시퀀스 분석
4. 예측된 단어와 정확도를 앱으로 반환
5. 앱에서 결과 표시 및 점수 기록

---

## 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.4.1 이상
- Dart SDK 3.4.1 이상
- Android Studio / Xcode (모바일 개발 환경)
- Android/iOS 디바이스 또는 에뮬레이터

### 설치 단계

1. **레포지토리 클론**
```bash
git clone https://github.com/yourusername/handtalker.git
cd handtalker/handtalk_0507
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 변수 설정**
`.env` 파일을 생성하고 필요한 설정을 추가합니다:
```env
API_BASE_URL=http://13.125.229.164
```

4. **앱 실행**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# 특정 디바이스 선택
flutter devices
flutter run -d [device_id]
```

5. **빌드 (배포용)**
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 프로젝트 구조

```
handtalk_0507/
├── lib/
│   ├── main.dart                          # 앱 진입점
│   ├── app.dart                           # 앱 설정 및 라우팅
│   ├── models/
│   │   └── user_model.dart                # 사용자 데이터 모델
│   ├── screens/
│   │   ├── screens/
│   │   │   ├── home_screen.dart           # 홈 화면
│   │   │   ├── course_screen.dart         # 코스 학습 화면
│   │   │   ├── ai_tutor_screen.dart       # AI 튜터 (수어 인식)
│   │   │   ├── ai_quiz_screen.dart        # AI 퀴즈 채점 화면
│   │   │   ├── nomal_quiz_screen.dart     # 일반 퀴즈 화면
│   │   │   ├── quiz_result_screen.dart    # 퀴즈 결과 화면
│   │   │   ├── words_list_screen.dart     # 단어 목록 화면
│   │   │   ├── word_quiz_screen.dart      # 단어 퀴즈 화면
│   │   │   ├── video_recorder_widget.dart # 비디오 녹화 위젯
│   │   │   └── sign_language_webview*.dart# 수어사전 웹뷰
│   │   ├── quiz_screen.dart               # 레거시 퀴즈 화면
│   │   └── result_screen.dart             # 레거시 결과 화면
│   ├── widgets/
│   │   └── home_screen_widgets.dart       # 홈 화면 위젯
│   └── src/
│       └── navigation/
│           └── main_navigation.dart        # 내비게이션 설정
├── assets/
│   ├── quiz_questions.json                # 96개 퀴즈 문제 데이터
│   └── images/                            # 이미지 리소스
├── android/                               # Android 설정
├── ios/                                   # iOS 설정
├── pubspec.yaml                           # Flutter 의존성 설정
└── README.md                              # 프로젝트 문서

주요 파일 설명:
- **quiz_questions.json**: 96개 수어 단어 및 영상 URL 데이터
- **ai_tutor_screen.dart**: 사용자 수어 동작 촬영 및 AI 인식
- **ai_quiz_screen.dart**: AI 서버로 비디오 업로드 및 채점
- **course_screen.dart**: 한국수어사전 웹뷰를 통한 카테고리별 학습
```

---

## 스크린샷

### 앱 메인 화면
![handtalker1](https://github.com/user-attachments/assets/27e2f3d7-af50-4a78-bc0a-f2e881f86db1)

### 학습 화면
![handtalker2](https://github.com/user-attachments/assets/052a0ea2-f3df-4262-83dd-60a6deb0ad75)

---

## 주요 기능 상세

### AI 수어 인식 시스템
- 서버 엔드포인트: `http://13.125.229.164/predict/`
- 입력: 비디오 파일 (MP4), 단어, 카테고리
- 출력: 예측 단어, 정답 여부, 정확도
- 타임아웃: 60초

### 퀴즈 데이터 구조
```json
{
  "word": "가족",
  "videoUrl": "https://sldict.korean.go.kr/multimedia/.../MOV000250034_700X466.webm"
}
```

### 학습 기록 저장 형식
```json
{
  "score": 8,
  "total": 10,
  "date": "2025-12-07T12:33:11.842Z"
}
```

---

## 향후 개선 계획
- [ ] 더 많은 수어 단어 추가 (현재 96개 → 500개+)
- [ ] 오프라인 모드 지원 (TFLite를 이용한 온디바이스 AI)
- [ ] 학습 통계 및 진도 대시보드
- [ ] 소셜 기능 (친구와 점수 경쟁)
- [ ] 음성 인식 기반 수어 번역 기능
- [ ] 다국어 지원 (영어, 일본어 등)

---

## 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 기여
이슈 제보 및 풀 리퀘스트를 환영합니다!

1. 이 레포지토리를 Fork 합니다
2. 새로운 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 Push 합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

---

## 문의
프로젝트 관련 문의사항이 있으시면 Issues 탭을 이용해주세요.

---

**Made with ❤️ for Korean Sign Language Learners**



![handtalker1](https://github.com/user-attachments/assets/27e2f3d7-af50-4a78-bc0a-f2e881f86db1)
[handtalker2](https://github.com/user-attachments/assets/052a0ea2-f3df-4262-83dd-60a6deb0ad75)

