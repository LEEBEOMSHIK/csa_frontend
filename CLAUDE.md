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
| [api-guidelines.md](claude-config/api-guidelines.md) | 서버 통신 규칙 (API 클라이언트) |

## 핵심 원칙
1. 요청된 것만 변경한다 — 과도한 리팩터링 금지
2. 불필요한 주석·docstring 추가 금지
3. 보안 취약점(XSS, Injection 등) 코드 작성 금지
4. 커밋은 명시적으로 요청받을 때만 생성한다

## 언어 설정 (다국어)

### 기본 사항
- 앱 지원 언어: **한국어(ko)**, **日本語(ja)** 2개 언어
- 언어 선택 UI: 마이 페이지 > 앱 설정 > `언어 설정` 메뉴
- 전역 언어 상태: `lib/utils/locale_provider.dart`의 `localeNotifier` (`ValueNotifier<Locale>`)
- `MaterialApp`이 `ValueListenableBuilder`로 감싸져 있어 언어 전환 시 앱 전체가 즉시 재빌드된다

### ARB 파일 구조
```
lib/l10n/
├── app_ko.arb              # 한국어 (템플릿 파일)
├── app_ja.arb              # 일본어
├── app_localizations.dart  # 자동 생성 — 직접 수정 금지
├── app_localizations_ko.dart
└── app_localizations_ja.dart
```
- `app_ko.arb`가 **템플릿**이다. 새 키를 추가할 때 반드시 이 파일을 먼저 수정한다.
- ARB 파일 수정 후 반드시 `flutter gen-l10n`을 실행해 생성 파일을 갱신한다.
- `app_localizations*.dart`는 자동 생성 파일이므로 직접 수정하지 않는다.

### 새 화면·위젯 개발 시 필수 절차

#### 1단계 — ARB에 키 추가
두 파일에 동시에 같은 키를 추가한다:

**`lib/l10n/app_ko.arb`**
```json
"myNewKey": "한국어 텍스트",
```

**`lib/l10n/app_ja.arb`**
```json
"myNewKey": "日本語テキスト",
```

플레이스홀더가 필요한 경우 (예: `{name}`, `{count}`):
```json
"greeting": "안녕하세요, {name}님!",
"@greeting": {
  "placeholders": {
    "name": { "type": "String" }
  }
}
```

#### 2단계 — 코드 재생성
```bash
flutter gen-l10n
```

#### 3단계 — 화면에서 사용
```dart
import 'package:csa_frontend/l10n/app_localizations.dart';

// build() 메서드 내부
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewKey)
Text(l10n.greeting('홍길동'))
```

### 임포트 경로
```dart
// ✅ 올바른 임포트
import 'package:csa_frontend/l10n/app_localizations.dart';

// ❌ 사용하지 않는다 (flutter_gen synthetic package 방식은 이 프로젝트에서 미사용)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 레이아웃 규칙
- UI 문자열을 하드코딩하지 않는다 — 반드시 ARB 키를 통해 가져온다
- 일본어는 한국어보다 텍스트가 길어질 수 있으므로, `Text` 위젯에 `overflow: TextOverflow.ellipsis` 또는 `Flexible`/`Expanded`로 감싸 overflow를 처리한다
- 고정 너비 컨테이너에 텍스트를 배치할 때는 두 언어 모두 테스트한다

### 언어 전환 코드 패턴
```dart
import 'package:csa_frontend/utils/locale_provider.dart';

// 한국어로 전환
localeNotifier.value = const Locale('ko');

// 일본어로 전환
localeNotifier.value = const Locale('ja');
```

### 콘텐츠 데이터 vs UI 문자열
- **ARB 대상**: 버튼 라벨, 섹션 헤더, 에러 메시지, 안내 문구 등 UI 고정 문자열
- **ARB 불필요**: 백엔드 API에서 받아오는 동화 제목·설명, 사용자 생성 데이터 등 콘텐츠

## 개발 명령어
```bash
# 의존성 설치
flutter pub get

# 다국어 코드 재생성 (ARB 수정 후 반드시 실행)
flutter gen-l10n

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
