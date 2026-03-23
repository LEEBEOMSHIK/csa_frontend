# error-reference.md — 오류 레퍼런스

발생했던 오류들을 기록한다. 유사한 문제 발생 시 이 파일을 먼저 참조한다.

---

## 오류 목록

| # | 오류 코드 | 서비스 | 발생 시점 | 상태 |
|---|-----------|--------|-----------|------|
| 1 | 403 PERMISSION_DENIED | Google People API | 2026-03-23 | 해결 |

---

## #1 — Google OAuth 로그인 시 403 PERMISSION_DENIED

### 발생 일자
2026-03-23

### 증상
Google OAuth 로그인 시도 시 아래 에러 발생:
```
Google login failed: ClientException: {
  "error": {
    "code": 403,
    "message": "People API has not been used in project 279288031280 before or it is disabled.",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "SERVICE_DISABLED",
        "domain": "googleapis.com",
        "metadata": {
          "service": "people.googleapis.com",
          "consumer": "projects/279288031280",
          "containerInfo": "279288031280"
        }
      }
    ]
  }
}
```

### 원인
Google Cloud 프로젝트(`279288031280`)에서 **People API(`people.googleapis.com`)가 비활성화** 상태였다.

OAuth 로그인 시 `profile` 스코프를 요청하면 Google이 사용자 프로필 정보를 가져오기 위해 내부적으로 People API를 호출한다. 이 API가 활성화되어 있지 않으면 403을 반환한다.

**트리거 스코프** (`lib/features/auth/services/google_auth_service.dart`):
```dart
scopes: ['email', 'profile', 'openid']
// 'profile' 스코프가 People API를 내부적으로 호출함
```

### 해결 방법
Google Cloud Console에서 People API 활성화:

1. 아래 URL 접속:
   ```
   https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=279288031280
   ```
2. **Enable** 버튼 클릭
3. 수 분 후 자동 적용 (코드 변경 불필요)

### 재발 조건
- Google Cloud 프로젝트를 새로 생성하거나 초기화한 경우
- People API가 실수로 비활성화된 경우
- 다른 Google Cloud 프로젝트로 전환한 경우

### 관련 파일
- `lib/features/auth/services/google_auth_service.dart` — OAuth 스코프 정의
- `lib/shared/services/api_client.dart` — API 에러 핸들링 (403 → `ApiExceptionType.client`)

### 주의사항
- 403 오류는 `api_client.dart`에서 401과 달리 **자동 재시도(token refresh)가 발생하지 않는다**
- Google Cloud Console 적용까지 최대 수 분 소요될 수 있다

---

## 새 오류 추가 양식

```markdown
## #N — [오류 제목]

### 발생 일자
YYYY-MM-DD

### 증상
[에러 메시지 전문 또는 재현 방법]

### 원인
[근본 원인 설명]

### 해결 방법
[단계별 해결 절차]

### 재발 조건
[언제 다시 발생할 수 있는지]

### 관련 파일
[관련 소스 파일 목록]
```
