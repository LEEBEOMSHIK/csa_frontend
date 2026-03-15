# non-touch.md — 분석 및 수정 금지 목록

이 파일에 등록된 파일 및 디렉터리는 **분석(Analysis)과 수정(Modification)을 모두 금지**한다.
Claude를 포함한 모든 자동화 도구는 아래 항목을 읽거나 변경하지 않는다.

## 금지 대상

### 플랫폼 네이티브 설정
| 경로 | 이유 |
|------|------|
| `android/` | Android 네이티브 빌드 설정 — 손대면 빌드 깨짐 위험 |
| `ios/` | iOS 네이티브 빌드 설정 — 코드서명·프로비저닝 포함 |
| `macos/` | macOS 네이티브 설정 |
| `windows/` | Windows 네이티브 설정 |
| `linux/` | Linux 네이티브 설정 |
| `web/` | Web 빌드 설정 |

### 자동 생성 파일
| 경로 | 이유 |
|------|------|
| `*.g.dart` | build_runner가 자동 생성 — 직접 수정 금지 |
| `*.freezed.dart` | Freezed가 자동 생성 — 직접 수정 금지 |
| `*.mocks.dart` | mockito가 자동 생성 — 직접 수정 금지 |
| `.dart_tool/` | Dart 내부 툴 캐시 |
| `.flutter-plugins` | Flutter 플러그인 자동 생성 목록 |
| `.flutter-plugins-dependencies` | 플러그인 의존성 자동 생성 |

### 민감 정보 및 비밀
| 경로 | 이유 |
|------|------|
| `.env` | API Key, Secret 등 민감 정보 포함 |
| `.env.*` | 환경별 민감 정보 |
| `dart_defines/` | dart-define 환경 변수 파일 |

### 빌드 산출물
| 경로 | 이유 |
|------|------|
| `/build/` | 빌드 결과물 — git 비추적 대상 |
| `/coverage/` | 테스트 커버리지 결과물 |
| `app.*.symbols` | 심볼리제이션 파일 |
| `app.*.map.json` | 난독화 맵 파일 |

---

## 규칙

1. **읽기 금지**: 위 목록의 파일 내용을 조회하거나 분석하지 않는다.
2. **수정 금지**: 어떠한 경우에도 직접 편집하지 않는다.
3. **예외 없음**: 사용자가 명시적으로 특정 파일의 수정을 요청하더라도, 먼저 이 목록에 포함된 항목인지 확인하고 경고한다.
4. **재생성 방법 안내**: 자동 생성 파일 수정이 필요할 경우 원본 소스(모델 클래스 등)를 수정 후 `flutter pub run build_runner build`를 실행하도록 안내한다.
