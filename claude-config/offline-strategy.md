# offline-strategy.md — 오프라인 동화 저장 전략

## 개요

앱 내에서 동화를 미리 저장하여 인터넷 없이도 감상할 수 있는 오프라인 저장 기능의 전략을 정의한다.
슬라이드 형식과 영상 재생 형식 각각의 저장 방법과 UI 노출 위치를 명시한다.

### 현재 저장소 현황
- `flutter_secure_storage` 설치됨 — 인증 토큰 전용
- `hive_flutter`, `path_provider` 미설치 — 오프라인 기능 구현 전 추가 필요

---

## 1. 오프라인 저장 기능 노출 위치

### 위치 A — 동화 상세 화면 (주요 진입점) ★
> 화면 파일: `lib/features/fairytale_detail/screens/fairytale_detail_screen.dart` (미구현)

동화 상세를 확인한 후 저장 여부를 결정하는 가장 자연스러운 흐름.

```
┌──────────────────────────────────┐
│  [썸네일 / 표지 이미지]           │
│  제목: 우주를 여행한 토끼          │
│  카테고리: AI 동화                │
├──────────────────────────────────┤
│  [▶ 슬라이드로 읽기]             │
│  [▶ 영상으로 보기]               │
│  [↓ 오프라인 저장]  [♥ 찜하기]   │
├──────────────────────────────────┤
│  다운로드 중: ████░░░░ 60%       │  ← 저장 진행 시 표시
└──────────────────────────────────┘
```

- "오프라인 저장" 버튼 탭 → 형식 선택 바텀시트 표시 (슬라이드 / 영상)
- 다운로드 중: 선형 진행 바 + 취소 버튼
- 완료 후: "저장됨" 상태로 버튼 변경 + 삭제 옵션 제공

---

### 위치 B — 동화 목록 화면 (보조 진입점)
> 화면 파일: `lib/features/fairytale_list/screens/fairytale_list_screen.dart`

그리드 카드 롱프레스 또는 카드 우하단 아이콘으로 빠른 저장.

```
┌─────────────┐
│  🚀          │
│  우주를 여행  │
│  한 토끼     │
│         [↓] │  ← 다운로드 아이콘 (우하단 오버레이)
└─────────────┘

완료 후:
┌─────────────┐
│  🚀    [✓] │  ← 오프라인 저장됨 배지
│  ...        │
└─────────────┘
```

- 저장되지 않은 동화: `Icons.download_outlined` 아이콘 표시
- 저장 완료: `Icons.offline_pin` 아이콘 + 배지 색상으로 상태 구분
- 아이콘 탭 → 간단한 확인 다이얼로그 → 다운로드 시작

---

### 위치 C — 찜목록 화면 (보조 진입점)
> 화면 파일: `lib/features/favorites/screens/favorites_screen.dart`

찜한 동화를 오프라인으로도 저장하는 흐름.

```
┌───────────────────────────────────────────┐
│ 🚀  우주를 여행한 토끼                      │
│     AI 동화                               │
│                    [▶ 재생]  [↓]  [♥]    │
└───────────────────────────────────────────┘
```

- trailing 영역에 다운로드 아이콘 `[↓]` 추가
- 저장 완료 시 `[✓]` 아이콘으로 변경
- 롱프레스 → 삭제 옵션 포함 컨텍스트 메뉴

---

### 위치 D — 마이 페이지 (저장 관리)
> 화면 파일: `lib/features/my/screens/my_screen.dart`

저장된 오프라인 동화 전체 관리.

```
앱 설정
  └─ 오프라인 저장 동화
       ├─ 저장된 동화: 3개 (총 128 MB)
       ├─ [저장 목록 보기 →]
       └─ [전체 삭제]
```

- 저장 목록 화면에서 개별 삭제 가능
- 총 사용 용량 표시 (`path_provider` + 파일 크기 합산)
- 자동 삭제 설정 (30일 미사용 시 삭제 등 TTL 옵션)

---

## 2. 형식별 저장 방법

### 슬라이드 형식 오프라인 저장

슬라이드 형식은 페이지 단위 데이터(텍스트, 이미지, 오디오)가 분리되어 있으므로 각각 다른 저장소에 저장한다.

#### 저장 구조

| 데이터 | 저장소 | 경로 / 키 |
|--------|--------|---------|
| 텍스트 + 페이지 메타 | **Hive** `offline_slide_box` | key: `fairytaleId` |
| 삽화 이미지 | **로컬 파일시스템** | `offline/{id}/page_{n}.png` |
| 오디오 (목소리별) | **로컬 파일시스템** | `offline/{id}/page_{n}_{voice}_{lang}.mp3` |
| 다운로드 상태/TTL | **Hive** `offline_meta_box` | key: `fairytaleId` |

#### 로컬 파일 경로 구조
```
{getApplicationDocumentsDirectory()}
└── offline/
    └── {fairytaleId}/
        ├── page_1.png
        ├── page_1_dad_ko.mp3
        ├── page_1_mom_ko.mp3
        ├── page_2.png
        ├── page_2_dad_ko.mp3
        └── ...
```

#### Hive 데이터 모델
```dart
// offline_slide_box
class OfflineSlideEntry {
  final String fairytaleId;
  final String title;
  final String thumbnailLocalPath;
  final List<OfflineSlidePage> pages;
  final DateTime downloadedAt;
}

class OfflineSlidePage {
  final int pageIndex;
  final String text;
  final String localImagePath;
  final Map<String, String> localAudioPaths; // 'dad_ko' → '/path/page_1_dad_ko.mp3'
}

// offline_meta_box
class OfflineMetaEntry {
  final String fairytaleId;
  final String format;       // 'slide' | 'video'
  final int totalSizeBytes;
  final DateTime downloadedAt;
  final DateTime? expiresAt; // TTL (null = 무기한)
  final DownloadStatus status; // downloading | completed | failed
}
```

#### 다운로드 순서
```
1. 메타 API 호출: GET /fairytale/{id}/slides
2. 각 페이지의 imageUrl → 로컬 파일로 순차 다운로드
3. 선택한 목소리의 audioUrl → 로컬 파일로 순차 다운로드
4. 텍스트 + 경로 정보 → Hive offline_slide_box 저장
5. 다운로드 상태 → Hive offline_meta_box 업데이트
```

---

### 영상 재생 형식 오프라인 저장

영상 형식은 단일 mp4 파일 전체를 로컬에 다운로드한다.

#### 저장 구조

| 데이터 | 저장소 | 경로 / 키 |
|--------|--------|---------|
| mp4 영상 파일 | **로컬 파일시스템** | `offline/{id}/video.mp4` |
| 메타데이터 | **Hive** `offline_video_box` | key: `fairytaleId` |
| 다운로드 상태/TTL | **Hive** `offline_meta_box` | key: `fairytaleId` |

#### 로컬 파일 경로 구조
```
{getApplicationDocumentsDirectory()}
└── offline/
    └── {fairytaleId}/
        └── video.mp4
```

#### Hive 데이터 모델
```dart
// offline_video_box
class OfflineVideoEntry {
  final String fairytaleId;
  final String title;
  final String thumbnailLocalPath;
  final String localVideoPath;
  final int fileSizeBytes;
  final DateTime downloadedAt;
}
```

#### 다운로드 순서
```
1. 영상 URL 조회: GET /fairytale/{id}/video
2. mp4 파일을 dio로 스트리밍 다운로드 (진행률 tracking)
3. {appDocDir}/offline/{id}/video.mp4 에 저장
4. 메타데이터 → Hive offline_video_box 저장
5. 다운로드 상태 → Hive offline_meta_box 업데이트
```

---

## 3. 다운로드 관리 서비스

```
lib/shared/services/download_manager.dart
```

### 역할
- 슬라이드/영상 형식 공통 다운로드 진입점
- 진행률 `Stream<double>` 제공 (0.0 ~ 1.0)
- 동시 다운로드 큐 관리 (최대 1개 동시 진행)
- 취소 기능
- 저장 완료 여부 확인 (`isOfflineAvailable(fairytaleId)`)
- TTL 만료 항목 자동 정리

### 사용 패턴
```dart
final downloadManager = DownloadManager.instance;

// 다운로드 시작
await downloadManager.downloadSlide(fairytaleId: 'abc', voiceType: 'dad', language: 'ko');

// 진행률 구독
downloadManager.progressStream(fairytaleId: 'abc').listen((progress) {
  // 0.0 ~ 1.0
});

// 오프라인 여부 확인
final isAvailable = downloadManager.isOfflineAvailable('abc'); // bool

// 삭제
await downloadManager.delete('abc');
```

---

## 4. 온/오프라인 전환 처리

`connectivity_plus` 패키지로 네트워크 상태를 감지하여 자동 전환.

```
온라인 상태:
  → 동화 목록: 서버 API 호출
  → 슬라이드 재생: CDN 이미지/오디오 스트리밍
  → 영상 재생: CDN mp4 스트리밍

오프라인 상태:
  → 동화 목록: Hive offline_meta_box 기반 저장된 목록만 표시
  → 슬라이드 재생: 로컬 파일 경로로 대체
  → 영상 재생: 로컬 mp4 파일 경로로 대체
  → 미저장 동화 접근 시: "오프라인에서 이용 불가" 안내 메시지
```

---

## 5. 추가 필요 패키지

| 패키지 | 용도 |
|--------|------|
| `hive_flutter` | 메타데이터 로컬 저장 |
| `path_provider` | 앱 로컬 파일시스템 경로 |
| `connectivity_plus` | 네트워크 상태 감지 |
| `dio` | 파일 다운로드 (이미 설치됨) |

---

## 6. 저장 용량 가이드

| 형식 | 페이지/파일당 용량 | 5챕터 기준 |
|------|-----------------|----------|
| 슬라이드 이미지 | ~500 KB/장 | ~2.5 MB |
| 슬라이드 오디오 (목소리 1개) | ~300 KB/페이지 | ~1.5 MB |
| 영상 (mp4, standard) | — | ~30~80 MB |
| 영상 (mp4, premium) | — | ~80~200 MB |

> 슬라이드 형식은 목소리 1개 기준 약 4~5 MB. 영상 형식은 최소 30 MB.
> 마이 페이지에서 총 사용 용량을 사용자에게 표시한다.

---

## 7. 금지 사항

- 서버 API 응답 전체를 만료 기간 없이 무기한 캐싱 금지 (TTL 설정 필수)
- 오디오 파일을 SharedPreferences에 저장 금지 (반드시 파일시스템 사용)
- 다운로드 진행 중 앱 종료 시 부분 저장된 파일 방치 금지 (재시작 시 정리)
- Wi-Fi 미연결 상태에서 대용량 영상 자동 다운로드 금지 (사용자 확인 필수)
