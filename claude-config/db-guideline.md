# db-guideline.md — 데이터 저장 규칙

## 저장 위치 분류

데이터는 **디바이스 로컬**과 **서버 DB** 두 곳으로 나뉜다.

---

## 1. 디바이스 로컬 저장 (Device Local)

앱이 오프라인이거나 빠른 응답이 필요할 때 사용한다.

### 1-1. SharedPreferences (키-값 단순 설정)
패키지: `shared_preferences`

| 데이터 | 키 이름 | 타입 | 비고 |
|--------|---------|------|------|
| 알림 설정 - 텍스트 | `noti_text_enabled` | bool | 기본값 true |
| 알림 설정 - 푸시 | `noti_push_enabled` | bool | 기본값 true |
| 자동 로그인 여부 | `auto_login` | bool | - |
| 마지막 선택 탭 | `last_tab_index` | int | - |

**사용 규칙**
- 단순 on/off 설정, 마지막 상태값만 저장한다.
- 민감한 정보(토큰, 비밀번호)는 절대 저장하지 않는다.

---

### 1-2. flutter_secure_storage (암호화 저장소)
패키지: `flutter_secure_storage`

| 데이터 | 키 이름 | 비고 |
|--------|---------|------|
| 액세스 토큰 | `access_token` | 암호화 필수 |
| 리프레시 토큰 | `refresh_token` | 암호화 필수 |
| 사용자 ID | `user_id` | - |

**사용 규칙**
- 인증 관련 토큰은 반드시 secure_storage에 저장한다.
- SharedPreferences나 일반 파일에 토큰 저장 금지.

---

### 1-3. Hive (로컬 NoSQL DB)
패키지: `hive_flutter`

| Box 이름 | 저장 데이터 | 모델 |
|----------|-----------|------|
| `character_box` | 내 캐릭터 파츠 선택값 (얼굴/머리/눈/코/입) | `CharacterModel` |
| `favorites_box` | 즐겨찾기 동화 목록 | `FavoriteItem` |
| `draft_box` | 동화 만들기 임시저장 | `FairytaleDraft` |
| `slide_cache_box` | 슬라이드 형식 동화 페이지 데이터 캐시 | `SlideCacheEntry` |

**사용 규칙**
- 구조화된 객체는 Hive TypeAdapter를 정의하여 사용한다.
- 민감 정보 저장 금지.
- Box는 기능 단위로 분리한다.

---

## 2. 서버 DB 저장 (Remote DB)

서버에 저장되어야 하는 데이터 기준:
- 여러 기기에서 동기화가 필요한 데이터
- 다른 사용자와 공유되는 데이터
- 결제·구독 관련 데이터
- 생성된 콘텐츠 (동화, 이미지 등)

| 데이터 | 설명 |
|--------|------|
| 사용자 계정 정보 | 이름, 이메일, 프로필 이미지 URL |
| 캐릭터 정보 | 최종 저장된 캐릭터 구성 |
| 생성된 동화 | 제목, 내용, 이미지, 카테고리, 출력 형식(slide/video) |
| 슬라이드 페이지 데이터 | `List<{ pageIndex, imageUrl, text }>` — 슬라이드 형식 동화 전용 |
| 영상 URL | CDN 영상 파일 경로 — 영상 재생 형식 동화 전용 |
| 즐겨찾기 목록 | 서버 동기화 대상 |
| 구독·결제 정보 | 서버 단독 관리 |

---

## 3. 저장 위치 결정 기준

```
민감한 인증 정보?
  └─ YES → flutter_secure_storage

단순 설정값 (on/off, 마지막 상태)?
  └─ YES → SharedPreferences

구조화된 오프라인 데이터?
  └─ YES → Hive

여러 기기 동기화 또는 공유 데이터?
  └─ YES → 서버 DB
```

---

## 4. 금지 사항

- SharedPreferences에 토큰·비밀번호 저장 금지
- 민감 정보를 평문 파일로 저장 금지
- 서버 DB 데이터를 로컬에 무기한 캐싱 금지 (TTL 설정 필요)
- Hive Box에 암호화 없이 인증 정보 저장 금지
