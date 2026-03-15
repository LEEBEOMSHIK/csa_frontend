# csa_frontend — 동화 만들기 앱 (Fairy Tale App)

## 프로젝트 개요

어린이가 터치로 자신만의 캐릭터를 만들고, AI가 동화를 생성하며,
아빠·엄마·할머니·할아버지의 목소리로 동화를 읽어주는 **가족 동화 앱**.

- **버전**: 1.0.0+1
- **프레임워크**: Flutter (SDK ^3.10.0)
- **지원 플랫폼**: Android, iOS
- **타겟 사용자**: 어린이 및 가족

### 핵심 가치
- 어린이의 **창의력** 자극 (캐릭터 제작, 동화 선택)
- **가족의 목소리**로 읽어주는 따뜻한 경험 (아빠, 엄마, 할머니, 할아버지)
- AI 기반 **맞춤 동화 생성**
- 어린이 친화적 **터치 UX**

---

## 앱 구조 — 하단 네비게이션 (4개 메뉴)

```
┌─────────────────────────────────────┐
│              콘텐츠 영역             │
├──────────┬──────────┬───────┬───────┤
│  내 캐릭터 │ 동화 만들기 │기본동화│  찜   │
└──────────┴──────────┴───────┴───────┘
```

| 메뉴 | 설명 |
|------|------|
| **내 캐릭터** | 터치로 캐릭터 파츠(머리형, 눈, 코, 입, 헤어, 의상 등) 선택 및 저장 |
| **동화 만들기** | 카테고리 선택 후 AI로 동화 자동 생성, 내 캐릭터 삽입 가능 |
| **기본 동화** | 유명 동화·AI 생성 동화·공유 동화 목록, 가족 목소리 TTS 재생 |
| **찜** | 즐겨찾기 동화 모아보기, 오프라인 저장 지원 예정 |

---

## 초기 세팅 및 시작 전 확인 사항

### 1. 환경 요구사항

| 항목 | 요구 버전 |
|------|-----------|
| Flutter | stable 채널, SDK ^3.10.0 |
| Dart | ^3.10.0 (null safety 필수) |
| Android Studio / Xcode | 최신 stable 권장 |

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. 개발 서버 실행

```bash
# 디버그 실행 (연결된 디바이스 또는 에뮬레이터 필요)
flutter run

# 특정 플랫폼 지정 실행
flutter run -d android
flutter run -d ios
```

### 4. 빌드

```bash
flutter build apk      # Android
flutter build ios      # iOS
```

### 5. 린트 & 테스트

```bash
flutter analyze        # 린트 검사 (에러 없는 상태로 커밋)
flutter test           # 단위/위젯 테스트
```

### 6. API Key 및 민감 정보 설정

민감 정보는 소스코드에 하드코딩하지 않는다. `--dart-define`으로 주입한다.

```bash
flutter run --dart-define=API_KEY=your_key_here
```

`.env` 파일 사용 시 반드시 `.gitignore`에 등록할 것.

---

## 디렉터리 구조

```
csa_frontend/
├── lib/
│   ├── main.dart
│   ├── app/                      # MaterialApp 루트, 라우팅
│   ├── features/
│   │   ├── character/            # 내 캐릭터 기능
│   │   ├── fairytale_create/     # 동화 만들기 기능
│   │   ├── fairytale_list/       # 기본 동화 기능
│   │   └── favorites/            # 찜 기능
│   ├── shared/                   # 공통 위젯, 서비스, 모델
│   └── utils/                    # 색상, 간격, 에셋 상수
├── assets/
│   ├── character_parts/          # 캐릭터 파츠 이미지 (head, eyes, nose, mouth, hair, outfit)
│   ├── fairytales/               # 기본 동화 썸네일·삽화
│   ├── images/                   # UI 이미지
│   └── audio/                    # 샘플 TTS 오디오
├── test/                         # 테스트 코드
├── claude-config/                # Claude 세부 설정 파일
└── pubspec.yaml
```

---

## 현재 개발 단계

- [x] 프로젝트 초기 세팅 (Flutter)
- [x] Claude 설정 파일 구성
- [ ] 프로젝트 구조 재편 (feature 기반 폴더 구조)
- [ ] 하단 네비게이션 바 구현 (4개 메뉴)
- [ ] 내 캐릭터 — 캐릭터 파츠 선택 UI 구현
- [ ] 동화 만들기 — 카테고리 선택 UI 구현
- [ ] 동화 만들기 — AI 동화 생성 API 연동
- [ ] 기본 동화 — 동화 목록/상세 화면 구현
- [ ] 기본 동화 — TTS 가족 목소리 연동
- [ ] 찜 기능 구현
- [ ] 공유 동화 커뮤니티 기능
- [ ] 테스트 작성
- [ ] Android / iOS 배포 준비

---

## 주요 의존성

| 패키지 | 용도 |
|--------|------|
| cupertino_icons | iOS 스타일 아이콘 |
| flutter_lints | 코드 품질 lint |
| go_router | 화면 라우팅 |
| flutter_tts | TTS (텍스트 음성 변환) |
| cached_network_image | 이미지 캐싱 |
| shared_preferences | 로컬 데이터 저장 |
| dio | HTTP API 통신 |

> Flame(^1.18.0)은 현재 의존성에 포함되어 있으나, 동화 앱 특성상 필요 여부를 재검토할 것.

---

## 백엔드 API (예정)

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/fairytale/generate` | AI 동화 생성 |
| GET | `/fairytale/list` | 동화 목록 조회 |
| POST | `/fairytale/share` | 동화 공유 |
| GET | `/fairytale/{id}` | 동화 상세 조회 |
| POST | `/user/character` | 캐릭터 저장 |

> 백엔드 API 서버 정보는 확정 후 업데이트 예정.

---

## 코드 가이드라인 요약

- **네이밍**: 클래스 `UpperCamelCase`, 함수/변수 `lowerCamelCase`, 파일/디렉터리 `snake_case`
- **위젯**: `StatelessWidget` 기본, 상태 필요 시만 `StatefulWidget`
- **스타일**: Material 3 테마, 색상·간격·에셋 경로는 상수로 관리 (`AppColors`, `AppSpacing`, `AppAssets`)
- **간격 단위**: 8px 배수 (4, 8, 16, 24, 32)
- **보안**: API Key 하드코딩 금지, HTTPS만 사용, 민감 데이터는 `flutter_secure_storage` 사용

세부 규칙은 [`claude-config/`](claude-config/) 폴더를 참조한다.

---

## 참고 자료

- [Flutter 공식 문서](https://docs.flutter.dev)
- [flutter_tts 패키지](https://pub.dev/packages/flutter_tts)
- [go_router 패키지](https://pub.dev/packages/go_router)
- [Dart 언어 가이드](https://dart.dev/language)
