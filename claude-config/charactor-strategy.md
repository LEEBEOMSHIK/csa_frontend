# charactor-strategy.md — 캐릭터 화면 2D 게임형 전환 전략

> 참고 이미지: `test/1.png` (통통한 마스코트 캐릭터 + 코스튬 드레스업 방식)

---

## 1. 레퍼런스 이미지 분석 (test/1.png)

### 캐릭터 스타일
- **고정 베이스 바디**: 통통한 새/펭귄 형태의 귀여운 마스코트 — 항상 동일한 몸체
- **레이어 방식**: 베이스 위에 코스튬(모자·상의·하의·악세서리)을 겹쳐서 합성
- 얼굴 특징(눈·코·입)은 커스터마이즈 대상이 **아님** — 마스코트 고정 표정

### 카테고리 구성 (좌측 탭 → 이미지 참조)
| 순서 | 카테고리 | 아이콘 예시 |
|------|---------|------------|
| 0 | 전체 (All) | grid_view |
| 1 | 모자 / 헤드기어 | `Icons.military_tech_rounded` |
| 2 | 상의 (Top) | `Icons.checkroom_rounded` |
| 3 | 하의 (Bottom) | `Icons.accessibility_rounded` |
| 4 | 안경 (Glasses) | `Icons.wb_sunny_outlined` |
| 5 | 악세서리 (Accessory) | `Icons.auto_awesome_rounded` |

### 아이템 그리드 스타일
- **4열** 그리드 (기존 3열 → 4열로 변경)
- 각 카드: **이미지 썸네일** + 올리브/세이지 그린 배경 (`#C8D89A` 계열)
- 선택된 아이템: 카드 좌상단에 **초록 체크마크** (`Icons.check_circle`)
- 선택 해제 가능: 이미 선택된 항목을 다시 탭하면 해제 (없음 상태)

### 미리보기 영역 (상단)
- 노란/주황 따뜻한 배경 위에 마스코트 전신 표시
- 장착 중인 아이템이 실시간으로 반영되어 보임
- 캐릭터 옆에 소형 동반 캐릭터(펫/친구) 배치 가능 (추후 확장)
- 캐릭터의 특정 부위 탭 → 해당 카테고리 탭 자동 활성화 (HitZone)

---

## 2. 기존 UI와의 변경 매핑

### 보존하는 구성 요소
| 구성 요소 | 상태 |
|---------|------|
| `AppTopBar` (제목, ✓ 버튼) | 유지 |
| 컨텐츠 탭바 (스토리 / 그림조각) | 유지 |
| 왼쪽 사이드 탭 **구조** (72px 너비, 아이콘+라벨) | 유지 |
| 오른쪽 옵션 그리드 **구조** (GridView) | 유지 |
| 색상 시스템 (`_activeColor = 0xFFFF7043`) | 유지 |

### 변경하는 내용
| 변경 대상 | Before | After |
|---------|--------|-------|
| 사이드 탭 내용 | 기본형·헤어·눈·코·입 (5개) | 전체·모자·상의·하의·안경·악세서리 (6개) |
| 옵션 그리드 내용 | 텍스트 라벨 카드 | 이미지 썸네일 카드 (아이콘 또는 Image.asset) |
| 그리드 열 수 | 3열 | 4열 |
| 그리드 선택 표시 | 오렌지 테두리 + 텍스트 bold | 초록 체크마크 오버레이 |
| 캐릭터 미리보기 | 이모지 😊 (140×140 원형) | 전신 마스코트 (Stack 레이어 합성) |
| 상태 변수 키 | [head, hair, eyes, nose, mouth] | [hat, top, bottom, glasses, accessory] |

---

## 3. 캐릭터 렌더링 구조

### 렌더링 방식: Flutter Stack + Image.asset
- Flame 미사용 (정적 합성 → CustomPainter 또는 Image.asset Stack)
- Phase 1: CustomPainter로 마스코트 베이스 + 컬러 블록 코스튬 프로토타입
- Phase 2: 실제 PNG 에셋으로 교체

### 레이어 순서 (아래 → 위)
```
Layer 6 (최상단) — 모자 / 헤드기어 (hat)      ← 머리 위 덮음
Layer 5          — 안경 (glasses)              ← 얼굴 위
Layer 4          — 상의 (top)                  ← 몸통 위
Layer 3          — 하의 (bottom)               ← 다리/허리
Layer 2          — 악세서리 (accessory)         ← 손 또는 옆 배치
Layer 1 (최하단) — 베이스 바디 (body, 고정)    ← 항상 동일
```

### 에셋 경로 규칙
```
assets/character_parts/
├── body/
│   └── body_default.png          # 고정 마스코트 바디 (새/펭귄형)
├── hat/
│   ├── hat_0.png                 # 없음 (투명)
│   ├── hat_1.png                 # 악마 뿔 헬멧 (레퍼런스 이미지 스타일)
│   ├── hat_2.png                 # 파라오 머리장식
│   ├── hat_3.png                 # 갈색 카우보이 햇
│   └── hat_4.png                 # 기타...
├── top/
│   ├── top_0.png                 # 없음 (투명)
│   ├── top_1.png                 # 흰 티셔츠 "BE MINE" 스타일
│   ├── top_2.png                 # 꽃무늬 셔츠
│   ├── top_3.png                 # 줄무늬 상의
│   └── top_4.png                 # 기타...
├── bottom/
│   ├── bottom_0.png              # 없음 (투명)
│   ├── bottom_1.png              # 청바지
│   ├── bottom_2.png              # 반바지
│   └── bottom_3.png              # 기타...
├── glasses/
│   ├── glasses_0.png             # 없음 (투명)
│   ├── glasses_1.png             # 선글라스 (초록)
│   ├── glasses_2.png             # 둥근 안경
│   └── glasses_3.png             # 기타...
└── accessory/
    ├── accessory_0.png           # 없음 (투명)
    ├── accessory_1.png           # 하트 머그컵 (레퍼런스 스타일)
    ├── accessory_2.png           # 책
    └── accessory_3.png           # 기타...
```

> **인덱스 0은 항상 "없음"(투명 레이어)**로 예약한다. 선택 해제 시 index=0으로 설정.

### 에셋 경로 생성 함수
```dart
String _assetPath(String part, int index) =>
    'assets/character_parts/$part/${part}_$index.png';
```

---

## 4. 상태 변수 재설계

### _selectedVariants 인덱스 매핑 변경
```dart
// Before
// [0]=기본형, [1]=헤어, [2]=눈, [3]=코, [4]=입

// After
// [0]=모자(hat), [1]=상의(top), [2]=하의(bottom),
// [3]=안경(glasses), [4]=악세서리(accessory)
final List<int> _selectedVariants = [0, 0, 0, 0, 0];
// 초기값 0 = 모두 "없음" 상태
```

### _selectedTabIndex 매핑 변경
```dart
// 0=전체(all), 1=모자(hat), 2=상의(top),
// 3=하의(bottom), 4=안경(glasses), 5=악세서리(accessory)
int _selectedTabIndex = 0;
```

> "전체" 탭(index=0) 선택 시 모든 카테고리 아이템을 혼합하여 그리드에 표시.

---

## 5. HitZone 설계 (캐릭터 탭 → 탭 전환)

### 파츠 영역 → 탭 인덱스 매핑
| 캐릭터 영역 | 탭 인덱스 | 카테고리 |
|------------|----------|---------|
| 머리 위쪽 (모자 영역) | 1 | 모자 |
| 눈 주변 (안경 영역) | 4 | 안경 |
| 몸통 상부 (상의 영역) | 2 | 상의 |
| 몸통 하부 / 다리 (하의 영역) | 3 | 하의 |
| 손 / 옆 공간 (악세서리) | 5 | 악세서리 |

### 구현 구조
```dart
SizedBox(
  width: 140, height: 180,
  child: Stack(
    children: [
      // 캐릭터 레이어 (아래 → 위)
      Image.asset('assets/character_parts/body/body_default.png'),
      if (_selectedVariants[2] > 0)
        Image.asset(_assetPath('bottom', _selectedVariants[2])),
      if (_selectedVariants[1] > 0)
        Image.asset(_assetPath('top', _selectedVariants[1])),
      if (_selectedVariants[3] > 0)
        Image.asset(_assetPath('glasses', _selectedVariants[3])),
      if (_selectedVariants[0] > 0)
        Image.asset(_assetPath('hat', _selectedVariants[0])),
      if (_selectedVariants[4] > 0)
        Image.asset(_assetPath('accessory', _selectedVariants[4])),

      // HitZone 레이어
      _HitZone(top: 0,   height: 45, tabIndex: 1),  // 모자
      _HitZone(top: 55,  height: 20, tabIndex: 4),  // 안경
      _HitZone(top: 75,  height: 40, tabIndex: 2),  // 상의
      _HitZone(top: 115, height: 35, tabIndex: 3),  // 하의
    ],
  ),
)
```

---

## 6. 옵션 그리드 카드 UI 변경

### 카드 디자인 (test/1.png 참조)
```dart
// 아이템 카드 구조
Stack(
  children: [
    // 배경: 세이지 그린 (#C8D89A) 또는 현재 Color(0xFFF5F5F5)
    Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFC8E6A0)   // 선택 시 연초록
            : const Color(0xFFF0F0E8),  // 미선택 시 크림
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF5CB85C) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(child: Image.asset(itemAssetPath, fit: BoxFit.contain)),
    ),
    // 선택 체크마크 (좌상단)
    if (isSelected)
      Positioned(
        top: 4, left: 4,
        child: const Icon(Icons.check_circle, color: Color(0xFF5CB85C), size: 16),
      ),
  ],
)
```

### 그리드 설정 변경
```dart
// Before: crossAxisCount: 3
// After:  crossAxisCount: 4
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 4,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  childAspectRatio: 1.0,
)
```

### "없음" 선택지
- 각 카테고리 그리드의 **첫 번째 아이템(index=0)**은 항상 "없음" 카드
- 없음 카드 디자인: 점선 테두리 + X 아이콘 또는 빈 실루엣

---

## 7. 캐릭터 데이터 모델

### CharacterModel (재설계)
```dart
class CharacterModel {
  final int hatVariant;         // 0~N (0=없음)
  final int topVariant;         // 0~N
  final int bottomVariant;      // 0~N
  final int glassesVariant;     // 0~N
  final int accessoryVariant;   // 0~N

  const CharacterModel({
    this.hatVariant = 0,
    this.topVariant = 0,
    this.bottomVariant = 0,
    this.glassesVariant = 0,
    this.accessoryVariant = 0,
  });

  String get hatAsset       => 'assets/character_parts/hat/hat_$hatVariant.png';
  String get topAsset       => 'assets/character_parts/top/top_$topVariant.png';
  String get bottomAsset    => 'assets/character_parts/bottom/bottom_$bottomVariant.png';
  String get glassesAsset   => 'assets/character_parts/glasses/glasses_$glassesVariant.png';
  String get accessoryAsset => 'assets/character_parts/accessory/accessory_$accessoryVariant.png';

  CharacterModel copyWith({...}) { ... }
}
```

---

## 8. 파츠 변경 애니메이션

| 상황 | 애니메이션 |
|------|-----------|
| 아이템 선택/해제 | `AnimatedSwitcher` fadeIn 150ms |
| HitZone 탭 | 탭된 파츠 영역 살짝 scale(1.05) bounce |
| ✓ 저장 완료 | 캐릭터 전체 scale(1.1) → 원복 + fade |

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 150),
  child: _selectedVariants[categoryIndex] > 0
      ? Image.asset(
          _assetPath(category, _selectedVariants[categoryIndex]),
          key: ValueKey('$category-${_selectedVariants[categoryIndex]}'),
        )
      : const SizedBox.shrink(key: ValueKey('none')),
)
```

---

## 9. 구현 단계 (Phase)

### Phase 1 — 구조 프로토타입 (에셋 없이)
- `_selectedTabIndex` 탭 범위: 5개 → 6개로 변경 (`_selectedVariants`: 5개 유지)
- 사이드 탭 라벨·아이콘 교체 (기본형/헤어/눈/코/입 → 전체/모자/상의/하의/안경/악세서리)
- 캐릭터 미리보기: 이모지 대신 CustomPainter로 마스코트 베이스 그리기 (통통한 원형 몸 + 눈)
- 옵션 그리드: 4열, 텍스트 대신 컬러 블록으로 아이템 표현
- HitZone 탭 → 탭 전환 동작 검증

### Phase 2 — 에셋 적용
- `assets/character_parts/` 디렉터리에 파츠 PNG 추가
- `pubspec.yaml` 에셋 경로 등록
- Image.asset 기반 레이어 합성 및 아이템 카드 썸네일 적용
- ARB 키 업데이트: 탭 라벨 (characterTabHat, characterTabTop, 등)

### Phase 3 — 저장·연동
- `CharacterModel` 직렬화 → `SharedPreferences` 저장
- 서버 API 연동 (`POST /user/character`)
- 동화 만들기 삽화에 완성 캐릭터 활용

---

## 10. ARB 키 변경 목록

기존 ARB 키를 제거하고 아래로 교체한다.

| 제거 (old) | 추가 (new) |
|-----------|-----------|
| `characterTabBasic` | `characterTabAll` |
| `characterTabHair` | `characterTabHat` |
| `characterTabEyes` | `characterTabTop` |
| `characterTabNose` | `characterTabBottom` |
| `characterTabMouth` | `characterTabGlasses` |
| — | `characterTabAccessory` |
| `faceRound`, `faceSquare`, ... | (제거, 에셋 경로로 대체) |
| `hairBob`, `hairLong`, ... | (제거, 에셋 경로로 대체) |
| `eyeDefault`, ... | (제거) |
| `noseSmall`, ... | (제거) |
| `mouthSmile`, ... | (제거) |

---

## 11. 수정 범위 요약

| 파일 | 변경 내용 |
|------|---------|
| `character_screen.dart` | 탭 정의·옵션 목록·그리드 열수·미리보기 위젯 교체 |
| `character_preview.dart` | 신규 — 마스코트 베이스 + 코스튬 레이어 Stack |
| `character_model.dart` | 신규 — hat/top/bottom/glasses/accessory 필드 |
| `app_ko.arb` / `app_ja.arb` | 탭 라벨 키 교체 |
| `pubspec.yaml` | `assets/character_parts/` 경로 등록 (Phase 2) |

---

## 12. 보존 금지 목록 (기존 면 커스터마이즈 방식)

아래는 레퍼런스 이미지와 맞지 않으므로 **사용하지 않는다**:
- 얼굴형(머리 모양) 커스터마이즈
- 눈·코·입·헤어 커스터마이즈 (마스코트 고정 표정)
- `CustomPainter` 기반 얼굴 드로잉 (Phase 2부터 Image.asset 레이어로 대체)
