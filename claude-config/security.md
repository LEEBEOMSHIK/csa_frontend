# security.md — 보안 및 권한 설정

## 1. 기본 원칙
- 보안 취약점(OWASP Top 10 기준)을 유발하는 코드를 작성하지 않는다.
- 인증·인가 로직은 항상 서버 사이드에서 최종 검증한다.
- 민감한 정보(API Key, Secret, 토큰 등)는 소스코드에 하드코딩하지 않는다.

## 2. 민감 정보 관리
- API Key, 비밀번호, 토큰 등은 **절대 소스코드에 포함하지 않는다**.
- 환경 변수 또는 `--dart-define` 플래그를 통해 주입한다.
  ```bash
  flutter run --dart-define=API_KEY=your_key_here
  ```
- `.env` 파일을 사용하는 경우 반드시 `.gitignore`에 등록한다.
- `flutter_dotenv` 같은 패키지 사용 시 `assets/` 에 포함되지 않도록 주의한다.

## 3. 네트워크 보안
- HTTP 통신은 허용하지 않는다 — HTTPS만 사용한다.
- Android: `android/app/src/main/AndroidManifest.xml`에서 `clearTextTrafficPermitted` 비활성화 유지.
- iOS: `ios/Runner/Info.plist`에서 `NSAllowsArbitraryLoads` 비활성화 유지.
- 인증서 핀닝(Certificate Pinning) 적용을 권장한다.

## 4. 데이터 저장
- `SharedPreferences`에는 민감 정보를 저장하지 않는다.
- 민감 데이터 로컬 저장 시 `flutter_secure_storage` 패키지를 사용한다.
- 사용자 데이터는 필요 최소한만 수집·보관한다.

## 5. 입력 값 검증
- 외부에서 들어오는 모든 입력값은 시스템 경계에서 검증한다.
- 사용자 입력을 직접 명령어·쿼리에 삽입하지 않는다.

## 6. 권한 관리
- 앱에서 요청하는 권한은 실제로 필요한 최소한으로 제한한다.
- 런타임 권한 요청 전에 사용자에게 목적을 명확히 안내한다.

## 7. 코드 리뷰 체크리스트
- [ ] 하드코딩된 시크릿이 없는가?
- [ ] HTTP 엔드포인트를 사용하지 않는가?
- [ ] `print()` 또는 로그에 민감 정보가 출력되지 않는가?
- [ ] 서드파티 패키지의 라이선스 및 보안 이슈를 확인했는가?
