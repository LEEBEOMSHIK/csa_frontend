# CLAUDE.md — 프로젝트 기본 설정

## 프로젝트 개요
- **프로젝트명**: csa_frontend
- **프레임워크**: Flutter (SDK ^3.10.0) + Flame 게임 엔진 ^1.18.0
- **플랫폼**: Android, iOS, Web, Windows, macOS, Linux

## 상세 설정 파일 참조
모든 세부 규칙은 `claude-config/` 폴더 내 파일을 참조한다.

| 파일 | 내용 |
|------|------|
| [security.md](claude-config/security.md) | 보안 및 권한 설정 |
| [code-guidelines.md](claude-config/code-guidelines.md) | 코드 기본 룰 |
| [style-guidelines.md](claude-config/style-guidelines.md) | 스타일 기본 룰 |
| [project-overview.md](claude-config/project-overview.md) | 프로젝트 현황 및 설명 |
| [non-touch.md](claude-config/non-touch.md) | 분석 및 수정 금지 목록 |
| [db-guideline.md](claude-config/db-guideline.md) | 데이터 저장 규칙 (로컬/서버 DB) |

## 핵심 원칙
1. 요청된 것만 변경한다 — 과도한 리팩터링 금지
2. 불필요한 주석·docstring 추가 금지
3. 보안 취약점(XSS, Injection 등) 코드 작성 금지
4. 커밋은 명시적으로 요청받을 때만 생성한다

## 개발 명령어
```bash
# 의존성 설치
flutter pub get

# 실행 (디버그)
flutter run

# 빌드
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# 테스트
flutter test

# 린트 검사
flutter analyze
```

## 디렉터리 구조
```
csa_frontend/
├── lib/              # Dart 소스코드 (메인 진입점: lib/main.dart)
├── test/             # 테스트 코드
├── assets/           # 이미지, 사운드 등 리소스 (추가 예정)
├── android/          # Android 네이티브 설정
├── ios/              # iOS 네이티브 설정
├── web/              # Web 설정
├── claude-config/    # Claude 세부 설정 파일
└── pubspec.yaml      # 패키지 의존성
```
