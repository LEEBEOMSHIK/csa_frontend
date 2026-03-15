# code-guidelines.md — 코드 기본 룰

## 1. 언어 및 버전
- **Dart SDK**: ^3.10.0 (null safety 필수)
- **Flutter**: 최신 stable 채널 사용
- **Flame**: ^1.18.0

## 2. 파일 및 디렉터리 구조
```
lib/
├── main.dart              # 앱 진입점
├── game/                  # Flame 게임 관련 클래스
│   ├── [game_name].dart   # FlameGame 서브클래스
│   ├── components/        # 게임 컴포넌트
│   └── scenes/            # 게임 씬
├── screens/               # Flutter 스크린 (메뉴, 설정 UI 등)
├── widgets/               # 재사용 위젯
├── models/                # 데이터 모델
├── services/              # API, 스토리지 등 서비스
└── utils/                 # 유틸리티, 상수
```

## 3. 네이밍 컨벤션
| 대상 | 컨벤션 | 예시 |
|------|--------|------|
| 클래스 / 열거형 | UpperCamelCase | `PlayerComponent`, `GameState` |
| 함수 / 변수 | lowerCamelCase | `loadAssets()`, `playerSpeed` |
| 상수 | lowerCamelCase (또는 `kConstant`) | `maxHealth`, `kTileSize` |
| 파일 | snake_case | `player_component.dart` |
| 디렉터리 | snake_case | `game/components/` |

## 4. Import 규칙

### 절대 경로 import 필수
프로젝트 내부 파일을 import할 때는 반드시 **절대 경로(package import)** 를 사용한다.
상대 경로(`../`, `../../` 등)는 사용하지 않는다.

```dart
// ✅ 올바른 방식 — 절대 경로
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/app_colors.dart';
import 'package:csa_frontend/features/home/screens/home_screen.dart';

// ❌ 잘못된 방식 — 상대 경로
import '../../../shared/widgets/app_top_bar.dart';
import '../../utils/app_colors.dart';
import '../screens/main_screen.dart';
```

### Import 순서
다음 순서로 작성하고 각 그룹 사이에 빈 줄을 둔다.
1. Dart SDK (`dart:`)
2. Flutter / 외부 패키지 (`package:flutter/`, `package:외부패키지/`)
3. 프로젝트 내부 (`package:csa_frontend/`)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:csa_frontend/shared/widgets/app_top_bar.dart';
import 'package:csa_frontend/utils/app_colors.dart';
```

### 에셋 경로
이미지, 폰트 등 에셋 경로는 `AppAssets` 상수 클래스에서 관리한다.
```dart
// ✅
Image.asset(AppAssets.characterHead);

// ❌
Image.asset('assets/character_parts/head/head_01.png');
```

## 5. Dart 코딩 규칙
- `var` 보다 명시적 타입 선언을 우선한다 (단, 타입이 명백한 경우 `var` 허용).
- `late` 키워드는 최소화하고, 반드시 초기화가 보장될 때만 사용한다.
- `dynamic` 타입 사용을 지양한다.
- null 허용 타입(`?`)은 필요한 경우에만 사용한다.
- `const` 생성자를 적극적으로 활용한다 (성능 최적화).

## 6. Flutter 위젯 규칙
- `StatelessWidget`을 기본으로 사용하고, 상태 관리가 필요할 때만 `StatefulWidget`을 사용한다.
- `const` 위젯을 적극 사용해 불필요한 리빌드를 방지한다.
- 위젯 파일 하나에 하나의 주요 위젯을 정의한다.
- `build()` 메서드가 복잡해지면 프라이빗 메서드나 별도 위젯으로 분리한다.

## 7. Flame 컴포넌트 규칙
- `Component`를 직접 상속하기보다 적합한 믹스인(`HasGameRef`, `CollisionCallbacks` 등)을 조합한다.
- `onLoad()`에서 비동기 초기화를 처리한다.
- `update()`는 가볍게 유지하고, 무거운 연산은 캐싱하거나 분리한다.
- 컴포넌트 간 직접 참조보다 이벤트 또는 게임 인스턴스를 통해 통신한다.

## 8. 에러 처리
- 예측 가능한 에러는 `try-catch`로 처리하고 사용자에게 적절한 피드백을 제공한다.
- `print()`는 개발 시에만 사용하고, 프로덕션에서는 로깅 패키지를 사용한다.
- 발생 가능성 없는 상황에 대한 방어 코드는 추가하지 않는다.

## 9. 테스트
- 비즈니스 로직(모델, 서비스)은 단위 테스트를 작성한다.
- 위젯 테스트는 주요 화면을 대상으로 작성한다.
- 테스트 파일은 `test/` 디렉터리에 소스 구조와 동일하게 구성한다.

## 10. 린트
- `analysis_options.yaml`의 lint 규칙을 준수한다.
- `flutter analyze` 에러가 없는 상태로 커밋한다.
- 경고(warning)도 무시하지 않고 해결한다.
