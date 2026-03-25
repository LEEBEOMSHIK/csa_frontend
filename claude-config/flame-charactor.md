# flame-charactor.md — 캐릭터 화면 Flame 2D 게임형 개선 전략

> 참고: `test/1.png` (통통한 마스코트 + 아이템 그리드 드레스업 레퍼런스)

---

## 1. 현재 상태 분석 (문제점)

### 캐릭터 미리보기 영역
| 항목 | 현재 | 문제 |
|------|------|------|
| 렌더링 | `CustomPainter` (정적) | 생기 없음 — 완전히 정지된 그림 |
| 배경 | 단색 `Color(0xFFFFF9E6)` | 게임 느낌 없음, 단조로움 |
| 애니메이션 | 없음 | 캐릭터가 살아있는 느낌이 없음 |
| 이펙트 | 없음 | 아이템 교체 시 아무 반응 없음 |
| 그림자/깊이 | 없음 | 2D 게임의 입체감 부재 |

### 아이템 그리드 카드
| 항목 | 현재 | 문제 |
|------|------|------|
| 카드 내용 | 단색 블록 + 텍스트 라벨 | 참고 이미지와 동떨어진 품질 |
| 배경색 | 아이템 색상(불투명) | 게임 UI 느낌이 없음 |
| 선택 표시 | 초록 테두리 + 체크 원 | 구현됐지만 시각 임팩트 부족 |
| 아이콘 | 없음 | 무엇인지 한눈에 파악 어려움 |
| 그라디언트/깊이 | 없음 | 플랫하고 밋밋함 |

---

## 2. Flame 도입 전략

### 왜 Flame인가?
- **게임 루프**: `update(dt)` 를 통한 매 프레임 부드러운 idle 애니메이션
- **파티클 시스템**: 코스튬 교체 시 반짝이 버스트 이펙트
- **컴포넌트 구조**: 배경 / 캐릭터 / 이펙트를 독립 레이어로 관리
- `GameWidget` 으로 Flutter 위젯 트리에 자연스럽게 임베드

### 통합 범위
- **Flame 적용**: 캐릭터 미리보기 영역 (200px 높이 영역)만 `GameWidget` 으로 교체
- **Flutter 유지**: 아이템 그리드, 탭바, AppTopBar — 그대로 Flutter 위젯
- 기존 `CharacterPainter` (`CustomPainter`) 는 Flame 컴포넌트 내부에서 재활용

---

## 3. Flame 컴포넌트 구조

```
CharacterGame (FlameGame)
├── _BackgroundComponent        ← 따뜻한 그라디언트 배경 + 구름 장식
├── _CharacterComponent         ← CharacterPainter 래핑 + idle bounce
│   └── (CharacterPainter 호출)  ← 기존 CustomPainter 재사용
├── _FloatingSparkle × 8        ← 배경에 떠다니는 반짝이 별
└── _BurstParticle × N          ← 아이템 교체 시 생성, 자동 제거
```

### CharacterGame 공개 API
```dart
// 스크린에서 게임 생성
final _characterGame = CharacterGame(variants: List.from(_selectedVariants));

// 아이템 교체 시 호출
_characterGame.equipItem(List.from(_selectedVariants));
```

### GameWidget 임베드
```dart
// character_screen.dart 미리보기 영역
SizedBox(
  width: double.infinity,
  height: 200,
  child: GameWidget(game: _characterGame),
)
```

---

## 4. 컴포넌트 명세

### _BackgroundComponent
- 상단 `Color(0xFFFFE082)` → 하단 `Color(0xFFFFF8DC)` 선형 그라디언트
- 왼쪽 상단, 오른쪽 상단에 반투명 흰색 구름 2개 (`drawCircle` 합성)
- 하단에 연한 지면선 (`strokeWidth: 2`)
- `onGameResize` 로 크기 변경에 대응

### _CharacterComponent
- `HasGameReference<CharacterGame>` 믹스인으로 `game.size` 접근
- **idle 애니메이션**: `_time += dt` + `sin(_time × 2.5) × 3.0` px 상하 bounce
- **그림자**: 캐릭터 발아래 타원 (`Color(0x22000000)`) — bounce 반대 방향으로 크기 변동
- `updateVariants(List<int>)` 호출 시 내부 `CharacterPainter` 인스턴스 교체
- `onGameResize` 에서 중앙 재배치

### _FloatingSparkle
- 고정 위치에서 sin 파형으로 상하 표류 (±6 px)
- sin 파형으로 투명도 변화 (alpha 0~0.7)
- 4-point star 형태 (`Canvas.drawPath`)
- 초기 phase 랜덤 → 전체가 동시에 깜빡이지 않음

### _BurstParticle
- `equipItem()` 호출 시 캐릭터 주변 14개 생성
- 방사형 초기 velocity + 중력(+200 px/s²)
- 0.7초 lifetime, 점진 fade + shrink 후 `removeFromParent()`
- 6가지 색상 순환 (오렌지/골드/그린/블루/핑크/퍼플)

---

## 5. 아이템 카드 개선 명세

### 기존 → 변경
| 항목 | Before | After |
|------|--------|-------|
| 배경 | 단색 블록 | 카테고리별 2-stop 그라디언트 |
| 내용 | 텍스트 라벨만 | 아이콘(IconData) + 텍스트 라벨 |
| 그림자 | `BoxShadow` 조건부 | 항상 미세 그림자 + 선택 시 컬러 글로우 |
| 선택 배지 | 체크 원 (16px) | 체크 원 (18px) + BoxShadow 글로우 |
| 없음 카드 | 회색 X 아이콘 | 점선 테두리 + `remove_circle_outline` |

### 카테고리별 아이콘 매핑
| 카테고리 | 아이템 | IconData |
|---------|--------|----------|
| 모자(0) | 악마 투구(1) | `Icons.whatshot` |
| 모자(0) | 파라오(2) | `Icons.account_balance` |
| 모자(0) | 카우보이(3) | `Icons.terrain` |
| 모자(0) | 마법사(4) | `Icons.auto_fix_high` |
| 상의(1) | 흰 티셔츠(1) | `Icons.checkroom` |
| 상의(1) | 꽃무늬(2) | `Icons.local_florist` |
| 상의(1) | 줄무늬(3) | `Icons.view_stream` |
| 상의(1) | 정장(4) | `Icons.business_center` |
| 하의(2) | 청바지(1) | `Icons.straighten` |
| 하의(2) | 반바지(2) | `Icons.crop_square` |
| 하의(2) | 스커트(3) | `Icons.architecture` |
| 안경(3) | 선글라스(1) | `Icons.wb_sunny` |
| 안경(3) | 둥근 안경(2) | `Icons.remove_red_eye` |
| 안경(3) | 별 안경(3) | `Icons.star` |
| 악세서리(4) | 하트 머그(1) | `Icons.coffee` |
| 악세서리(4) | 책(2) | `Icons.menu_book` |
| 악세서리(4) | 별 지팡이(3) | `Icons.auto_awesome` |

---

## 6. 구현 파일 목록

| 파일 | 변경 내용 |
|------|---------|
| `lib/features/character/widgets/character_game.dart` | **신규** — Flame CharacterGame + 4개 컴포넌트 |
| `lib/features/character/screens/character_screen.dart` | GameWidget 교체, _ItemCard 개선 |
| `lib/features/character/widgets/character_preview.dart` | 유지 (CharacterPainter를 game에서 import) |

---

## 7. 제약 사항 및 주의

1. **Phase 1 범위**: 실제 PNG 에셋 없음 → `CharacterPainter` + `IconData` 아이콘 사용
2. **Phase 2 업그레이드**: `assets/character_parts/` 에 PNG 추가 시 `CharacterPainter` → `Image.asset` 레이어로 전환
3. `GameWidget` 은 `FlameGame` 인스턴스를 자체 관리 → 별도 `dispose()` 불필요
4. `equipItem()` 내부에 `isLoaded` 가드 필수 (위젯 마운트 전 호출 방지)
5. `_BackgroundComponent.render()` 에서 `game.size` 직접 읽기 — `onGameResize` 불필요
6. `CharacterGame` 은 `const` 불가 → `initState()` 에서 생성, 필드로 보관

---

## 8. 미래 확장 (Phase 2+)

- `SpriteAnimationComponent` 로 프레임별 걷기/점프 애니메이션 추가
- `SpriteSheet` 기반 idle/equip/celebrate 3종 애니메이션 상태머신
- `FlameAudio` 로 아이템 장착 효과음 (`pop.ogg`) 재생
- 저장 버튼 탭 시 `CelebrationEffect` (confetti burst)
- 배경 parallax — 멀리 구름이 천천히 흘러가는 연출
