# mcp-interface.md — AI 연동 인터페이스 정의

## 개요

이 앱에서 사용하는 모든 AI 서비스 목록, 각 AI의 역할·입출력·추천 서비스·연동 방식을 정의한다.

### 핵심 원칙
- **프론트엔드는 AI API를 직접 호출하지 않는다.** 모든 AI 호출은 백엔드를 통해 중계한다.
- 생성된 결과물(이미지·오디오·영상)은 CDN에 저장하고, 프론트엔드에는 URL만 반환한다.
- 시간이 오래 걸리는 작업(영상 생성 등)은 **비동기 처리 + polling** 방식을 사용한다.

### 전체 아키텍처

```
Flutter 앱 (프론트엔드)
  └─ ApiClient (dio)
       └─ 백엔드 서버
            ├─ [AI-1] Claude API        → 동화 텍스트 생성
            ├─ [AI-2] DALL-E 3          → 동화 삽화 이미지 생성
            ├─ [AI-3] ElevenLabs        → 가족 목소리 TTS 낭독
            ├─ [AI-4] FFmpeg + Kling AI → 움직이는 영상 동화 생성
            └─ [AI-5] ElevenLabs Clone  → 실제 가족 목소리 복제 (예정)
```

---

## AI-1. 동화 텍스트 생성

### 역할
사용자가 선택한 배경/장르/테마/챕터수/캐릭터 정보를 기반으로 어린이 동화 텍스트를 AI가 생성한다.

### 추천 AI
**Claude API — `claude-sonnet-4-6` (Anthropic)** ✅ 권장

| 항목 | 내용 |
|------|------|
| 한국어/일본어 품질 | 매우 우수 |
| 어린이 안전 콘텐츠 | 기본 내장 (Constitutional AI) |
| 구조화 출력 (JSON) | 지원 |
| 문맥 이해 | 긴 캐릭터 설명 처리 가능 |

**대안**

| AI | 특징 |
|----|------|
| GPT-4o (OpenAI) | 한국어 우수, 대안 1순위 |
| Gemini 1.5 Pro (Google) | 한국어/일본어 안정적, 대안 2순위 |

### 입력 (Request)
```json
{
  "settings": ["adventure", "sea"],
  "genre": "classic",
  "theme": "courage",
  "chapter_count": 5,
  "character": {
    "use": true,
    "description": "짧은 갈색 머리, 둥근 눈, 파란 옷"
  },
  "language": "ko"
}
```

### 출력 (Response)
```json
{
  "title": "바닷속 용감한 아이",
  "pages": [
    { "pageIndex": 1, "text": "옛날 옛날, 바닷가 마을에..." },
    { "pageIndex": 2, "text": "어느 날 폭풍이 몰아쳐..." }
  ]
}
```

### 연동 엔드포인트
`POST /fairytale/generate`

---

## AI-2. 동화 삽화 이미지 생성

### 역할
동화 각 페이지의 텍스트와 캐릭터 설명을 기반으로 그림책 스타일의 삽화 이미지를 생성한다.

### 추천 AI
**DALL-E 3 (OpenAI)** ✅ 권장

| 항목 | 내용 |
|------|------|
| 그림책 스타일 | 매우 우수 |
| 프롬프트 이해도 | 높음 (한국어 프롬프트 → 영어 자동 변환 내장) |
| 이미지 일관성 | 시리즈 일관성은 프롬프트 관리 필요 |

**대안**

| AI | 특징 |
|----|------|
| Stable Diffusion XL | 자체 호스팅 가능, 파인튜닝 가능 |
| Imagen 3 (Google) | 고품질, 텍스트 렌더링 우수 |

### 입력 (Request)
```json
{
  "page_text": "폭풍이 몰아치는 바닷가에서 아이는 용기를 냈다",
  "character_description": "짧은 갈색 머리, 둥근 눈, 파란 옷을 입은 어린이",
  "art_style": "children_book_watercolor",
  "language": "ko"
}
```

### 출력 (Response)
```json
{
  "imageUrl": "https://cdn.example.com/fairytales/{id}/page_2.png"
}
```

### 연동 엔드포인트
`POST /fairytale/{id}/generate-image` (페이지 단위 호출)

---

## AI-3. TTS — 가족 목소리 낭독

### 역할
생성된 동화 텍스트를 아빠·엄마·할머니·할아버지 4가지 가족 목소리 페르소나로 낭독한 오디오를 생성한다.

### 추천 AI
**ElevenLabs** ✅ 권장 (한국어 + 일본어 + 목소리 복제 통합)

| 항목 | 내용 |
|------|------|
| 한국어 지원 | 지원 (자연스러운 편) |
| 일본어 지원 | 지원 |
| 목소리 페르소나 | 커스텀 Voice 생성 가능 (아빠/엄마/할머니/할아버지) |
| 음성 복제 | 지원 (AI-5 연계) |
| 감정 표현 | 매우 우수 |

**대안**

| AI | 특징 | 적합 언어 |
|----|------|---------|
| Naver Clova Voice | 한국어 최고 자연스러움 | ko 전용 |
| Google Cloud TTS (WaveNet/Neural2) | ko + ja 모두 안정적, 저렴 | ko, ja |
| Azure Cognitive Services TTS | 다국어 안정적 | ko, ja |

> **권장 전략**: 기본 서비스는 ElevenLabs 사용. 한국어 품질이 더 중요한 경우 Naver Clova Voice 병행 고려.

### 목소리 페르소나 정의

| voice_type | 특징 | 언어 |
|------------|------|------|
| `dad` | 낮고 안정적인 남성 목소리 | ko, ja |
| `mom` | 따뜻하고 부드러운 여성 목소리 | ko, ja |
| `grandma` | 정감 있는 노인 여성 목소리 | ko, ja |
| `grandpa` | 근엄하고 포근한 노인 남성 목소리 | ko, ja |

### 입력 (Request)
```json
{
  "text": "폭풍이 몰아치는 바닷가에서 아이는 용기를 냈다",
  "voice_type": "dad",
  "language": "ko"
}
```

### 출력 (Response)
```json
{
  "audioUrl": "https://cdn.example.com/fairytales/{id}/page_2_dad_ko.mp3",
  "durationMs": 4200
}
```

### 연동 엔드포인트
`POST /fairytale/{id}/tts`

---

## AI-4. 움직이는 영상 동화 생성

### 역할
슬라이드 삽화(이미지)와 나레이션 오디오를 합성하여 자동 재생되는 동화 영상(mp4)을 생성한다.

### 추천 방식

#### 방식 A — 서버 FFmpeg 파이프라인 ✅ 기본 권장
이미지 + 오디오를 합성하고 Ken Burns(천천히 확대/이동) 애니메이션 효과를 적용.

| 항목 | 내용 |
|------|------|
| 안정성 | 매우 높음 |
| 처리 속도 | 빠름 (서버 사이드) |
| 비용 | 서버 CPU 비용만 (외부 AI 비용 없음) |
| 결과물 예측 가능성 | 높음 |
| 영상 품질 | 정적 이미지 + 간단한 모션 |

#### 방식 B — Kling AI (AI 애니메이션) ✅ 고품질 옵션
정지 이미지를 AI가 분석하여 캐릭터와 배경이 자연스럽게 움직이는 영상으로 변환.

| 항목 | 내용 |
|------|------|
| 영상 품질 | 매우 높음 (자연스러운 모션) |
| 한국어 서비스 | 한국 서비스 (현지화 우수) |
| 어린이 동화 스타일 | 적합 |
| 처리 속도 | 느림 (이미지당 30초~수분) |
| 비용 | API 호출 단위 과금 |

**대안**

| AI | 특징 |
|----|------|
| RunwayML Gen-3 | 고품질 AI 영상, 영어 중심 |
| Pika Labs | 짧은 클립 애니메이션 |

> **권장 전략**: 기본은 FFmpeg 파이프라인 사용. 프리미엄 옵션으로 Kling AI 영상 제공.

### 입력 (Request)
```json
{
  "slides": [
    {
      "pageIndex": 1,
      "imageUrl": "https://cdn.example.com/.../page_1.png",
      "audioUrl": "https://cdn.example.com/.../page_1_dad_ko.mp3",
      "durationMs": 4200
    }
  ],
  "bgm_type": "calm",
  "quality": "standard"
}
```
> `quality`: `"standard"` → FFmpeg, `"premium"` → Kling AI

### 출력 (Response) — 비동기
```json
{
  "jobId": "video_job_abc123",
  "status": "processing",
  "estimatedSeconds": 60
}
```

### 상태 조회 (Polling)
```json
// GET /fairytale/{id}/video/status
{
  "jobId": "video_job_abc123",
  "status": "completed",
  "videoUrl": "https://cdn.example.com/fairytales/{id}/video.mp4"
}
```

### 연동 엔드포인트
- `POST /fairytale/{id}/generate-video` — 영상 생성 요청
- `GET /fairytale/{id}/video/status` — 생성 상태 polling
- `GET /fairytale/{id}/video` — 완성된 영상 URL 조회

---

## AI-5. 실제 가족 목소리 복제 (예정 기능)

### 역할
사용자가 직접 녹음한 가족의 목소리 샘플을 AI로 복제하여, AI-3의 TTS에 활용한다.
예: 실제 아빠 목소리로 동화를 읽어줌.

### 추천 AI
**ElevenLabs Voice Cloning** ✅ 권장

| 항목 | 내용 |
|------|------|
| 최소 샘플 | 30초 이상 |
| 권장 샘플 | 3분 이상 (품질 향상) |
| 한국어 지원 | 지원 |
| 일본어 지원 | 지원 |
| AI-3 연계 | 복제된 voice_id를 TTS 요청에 그대로 사용 |

**대안**: Resemble AI

### 입력 (Request)
```json
{
  "audioFile": "<base64 or multipart>",
  "voiceName": "우리 아빠",
  "voiceType": "dad"
}
```

### 출력 (Response)
```json
{
  "voiceId": "elabs_voice_xyz789",
  "voiceName": "우리 아빠"
}
```

### 연동 엔드포인트
`POST /user/voice-clone`

---

## 비동기 처리 흐름 (영상 생성)

```
① 앱 → POST /fairytale/{id}/generate-video
② 백엔드 → { jobId, status: "processing" }
③ 앱 → 5초 간격으로 GET /fairytale/{id}/video/status polling
④ 백엔드 → status: "completed", videoUrl: "..."
⑤ 앱 → 영상 재생 화면으로 이동
```

---

## AI 서비스 요약 비교표

| # | 기능 | 추천 AI | 대안 | 연동 방식 |
|---|------|---------|------|---------|
| AI-1 | 동화 텍스트 생성 | Claude API (claude-sonnet-4-6) | GPT-4o, Gemini 1.5 Pro | 동기 |
| AI-2 | 동화 삽화 이미지 생성 | DALL-E 3 | Stable Diffusion XL, Imagen 3 | 동기 |
| AI-3 | 가족 목소리 TTS | ElevenLabs | Naver Clova Voice, Google TTS | 동기 |
| AI-4 | 움직이는 영상 생성 | FFmpeg + Kling AI | RunwayML, Pika Labs | **비동기** |
| AI-5 | 실제 목소리 복제 | ElevenLabs Voice Cloning | Resemble AI | 비동기 (예정) |

---

## 금지 사항

- 프론트엔드(Flutter)에서 AI API 키를 직접 사용 금지
- AI API 키를 코드에 하드코딩 금지 (환경변수 또는 백엔드 관리)
- 어린이 개인정보(얼굴 사진 등)를 외부 AI에 전송 금지
