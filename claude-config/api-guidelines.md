# api-guidelines.md — 서버 통신 규칙

## 1. 기본 원칙

- 서버 통신은 **반드시** `lib/shared/services/api_client.dart`만 사용한다.
- 각 feature에서 직접 `dio` 또는 `http`를 import하여 사용하는 것을 금지한다.
- 모든 API 요청/응답 로직은 `ApiClient` 클래스를 통해 처리한다.

---

## 2. 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `dio` | 최신 | HTTP 클라이언트 (axios 상당) |
| `flutter_secure_storage` | 최신 | 토큰 저장 |

> `http` 패키지는 사용하지 않는다. `dio`로 통일한다.

---

## 3. 공통 파일 구조

```
lib/shared/services/
└── api_client.dart   # 서버 통신 단일 진입점
```

### ApiClient 역할
- `BaseUrl` 설정 및 관리
- 요청 헤더 (Authorization, Content-Type) 자동 주입
- 액세스 토큰 만료 시 리프레시 토큰으로 재발급 (interceptor)
- 공통 에러 처리 및 예외 변환

---

## 4. BaseURL 관리

```dart
// 환경별 base URL
const String _baseUrl = 'https://api.example.com'; // TODO: 확정 후 수정
```

- `dart-define` 또는 환경 설정 파일로 분리 예정
- 절대 코드에 하드코딩된 실제 URL을 커밋하지 않는다

---

## 5. 인증 처리 (Interceptor)

- 모든 요청에 `Authorization: Bearer <access_token>` 헤더를 자동 추가한다
- 401 응답 수신 시:
  1. `refresh_token`으로 새 액세스 토큰 발급 요청
  2. 성공 시 원래 요청 재시도
  3. 실패 시 로그인 화면으로 이동

---

## 6. 에러 처리 규칙

| 상황 | 처리 |
|------|------|
| 네트워크 없음 | `ApiException(type: network)` throw |
| 4xx 클라이언트 에러 | `ApiException(type: client, statusCode)` throw |
| 5xx 서버 에러 | `ApiException(type: server, statusCode)` throw |
| 타임아웃 | `ApiException(type: timeout)` throw |

- feature 레이어에서는 `try-catch`로 `ApiException`을 받아 UI에 반영한다.

---

## 7. API 엔드포인트 목록 (예정)

| Method | Path | 설명 |
|--------|------|------|
| POST | `/auth/login` | 로그인 |
| POST | `/auth/refresh` | 토큰 재발급 |
| POST | `/auth/logout` | 로그아웃 |
| GET | `/fairytale/list` | 동화 목록 조회 |
| GET | `/fairytale/{id}` | 동화 상세 조회 |
| POST | `/fairytale/generate` | AI 동화 생성 |
| POST | `/fairytale/share` | 동화 공유 |
| POST | `/user/character` | 캐릭터 저장 |
| GET | `/user/profile` | 사용자 프로필 조회 |
| GET | `/user/favorites` | 찜목록 조회 |

---

## 8. 사용 예시

```dart
// feature 레이어에서의 사용
import 'package:csa_frontend/shared/services/api_client.dart';

final apiClient = ApiClient.instance;

// GET 요청
final response = await apiClient.get('/fairytale/list');

// POST 요청
final response = await apiClient.post(
  '/fairytale/generate',
  data: {'category': 'adventure', 'characterId': 'abc123'},
);
```

---

## 9. 금지 사항

- feature 코드에서 `dio` 직접 사용 금지
- feature 코드에서 `http` 패키지 사용 금지
- 토큰을 요청 코드에 직접 하드코딩 금지
- API URL을 각 feature 파일에 분산 정의 금지
