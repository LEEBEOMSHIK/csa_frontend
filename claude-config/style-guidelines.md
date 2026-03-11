# style-guidelines.md — 스타일 기본 룰

## 1. 테마 및 디자인 시스템
- `ThemeData`를 중앙에서 정의하고, 인라인 색상·폰트 하드코딩을 지양한다.
- `ColorScheme.fromSeed()` 기반의 Material 3 테마를 기본으로 사용한다.
- 커스텀 색상은 `utils/app_colors.dart` 등 별도 파일에서 상수로 관리한다.

## 2. 색상 가이드
```dart
// 예시: lib/utils/app_colors.dart
class AppColors {
  static const primary = Color(0xFF주색상);
  static const secondary = Color(0xFF보조색상);
  static const background = Color(0xFF배경색상);
  static const surface = Color(0xFF서피스색상);
  static const error = Color(0xFFB00020);
}
```
- 다크 모드를 고려해 시맨틱 색상(`Theme.of(context).colorScheme`)을 우선 사용한다.

## 3. 타이포그래피
- 폰트는 `pubspec.yaml`의 `fonts` 섹션에 등록하여 사용한다.
- 텍스트 스타일은 `Theme.of(context).textTheme`을 활용한다.
- 임의의 `fontSize`·`fontWeight` 하드코딩을 지양한다.

## 4. 간격 및 레이아웃
- 간격 단위는 8px 배수를 기준으로 한다 (8, 16, 24, 32 ...).
- 상수로 정의해서 사용한다.
  ```dart
  class AppSpacing {
    static const xs = 4.0;
    static const sm = 8.0;
    static const md = 16.0;
    static const lg = 24.0;
    static const xl = 32.0;
  }
  ```
- `MediaQuery`나 `LayoutBuilder`를 사용해 반응형 레이아웃을 구성한다.

## 5. 아이콘
- Material Icons(`Icons.*`)를 기본으로 사용한다.
- 커스텀 아이콘은 `assets/icons/` 에 SVG 또는 PNG로 저장한다.
- 아이콘 크기도 상수로 관리한다.

## 6. 에셋 관리
```
assets/
├── images/        # 배경, UI 이미지
├── icons/         # 아이콘
├── audio/         # 배경음악, 효과음
├── sprites/       # 게임 스프라이트 시트
└── fonts/         # 커스텀 폰트
```
- 모든 에셋은 `pubspec.yaml`의 `assets` 섹션에 등록한다.
- 에셋 경로는 상수로 관리한다.
  ```dart
  class AppAssets {
    static const playerSprite = 'assets/sprites/player.png';
    static const bgm = 'assets/audio/bgm.mp3';
  }
  ```

## 7. Flame 게임 UI 스타일
- 게임 내 HUD(체력바, 점수판 등)는 `FlameGame`의 `camera.viewport`를 통해 구성한다.
- Flutter UI(메뉴, 팝업)와 Flame 렌더링을 명확히 분리한다 (`GameWidget` 위에 Flutter 위젯 오버레이).
- 게임 씬 전환 애니메이션은 일관된 스타일을 유지한다.

## 8. 애니메이션
- Flutter 애니메이션: `AnimationController` + `Tween` 또는 `AnimatedWidget` 계열 사용.
- Flame 애니메이션: `SpriteAnimation`을 활용하고 프레임 레이트를 명시한다.
- 애니메이션 지속 시간은 상수로 관리한다.

## 9. 코드 포맷
- Dart 공식 포매터를 사용한다: `dart format .`
- 한 줄 최대 길이: 80자 (dart format 기본값).
- 저장 시 자동 포맷을 IDE에서 활성화한다.
