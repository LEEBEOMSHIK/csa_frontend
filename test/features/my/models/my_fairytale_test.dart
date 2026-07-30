import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/models/my_fairytale.dart';

/// `MyFairytale.isPlayable`은 백엔드 `AiFairytaleService.isServableAsSlides()`와
/// **동일한 범위**를 유지해야 하는 암묵적 계약이다.
///
/// 백엔드 판정:
/// ```java
/// if ("COMPLETED".equals(status)) return true;
/// return "video".equals(format) && "FAILED".equals(status) && !pages.isEmpty();
/// ```
///
/// 프론트가 더 넓으면 열 수 없는 동화를 열려다 409(INVALID_STATE)가 사용자에게 노출되고,
/// 더 좁으면 볼 수 있는 콘텐츠를 못 본다.
/// 이 테스트가 깨지면 양쪽 중 한쪽이 바뀐 것이므로 반드시 함께 맞춘다.
void main() {
  group('MyFairytale.isPlayable / isVideoAssemblyFailed', () {
    test('COMPLETED slide is playable and is not a video assembly failure', () {
      final fairytale = _fairytale(
        format: 'slide',
        status: 'COMPLETED',
        pageCount: 3,
      );

      expect(fairytale.isPlayable, isTrue);
      expect(fairytale.isVideoAssemblyFailed, isFalse);
    });

    test('COMPLETED video is playable regardless of format', () {
      final fairytale = _fairytale(
        format: 'video',
        status: 'COMPLETED',
        pageCount: 3,
      );

      expect(fairytale.isPlayable, isTrue);
      expect(fairytale.isVideoAssemblyFailed, isFalse);
    });

    test('COMPLETED stays playable even when pageCount is 0', () {
      // 백엔드도 COMPLETED면 pages 개수와 무관하게 항상 servable로 본다.
      final fairytale = _fairytale(
        format: 'video',
        status: 'COMPLETED',
        pageCount: 0,
      );

      expect(fairytale.isPlayable, isTrue);
      expect(fairytale.isVideoAssemblyFailed, isFalse);
    });

    test('FAILED video with pages is playable as a slide fallback '
        '(ffmpeg assembly failed only)', () {
      final fairytale = _fairytale(
        format: 'video',
        status: 'FAILED',
        pageCount: 5,
      );

      expect(fairytale.isVideoAssemblyFailed, isTrue);
      expect(fairytale.isPlayable, isTrue);
    });

    test('FAILED video without pages is not playable', () {
      final fairytale = _fairytale(
        format: 'video',
        status: 'FAILED',
        pageCount: 0,
      );

      expect(fairytale.isVideoAssemblyFailed, isFalse);
      expect(fairytale.isPlayable, isFalse);
    });

    test('FAILED slide is a real failure and is never playable', () {
      final fairytale = _fairytale(
        format: 'slide',
        status: 'FAILED',
        pageCount: 5,
      );

      expect(fairytale.isVideoAssemblyFailed, isFalse);
      expect(fairytale.isPlayable, isFalse);
    });

    test('GENERATING is not playable yet', () {
      final generatingSlide = _fairytale(
        format: 'slide',
        status: 'GENERATING',
        pageCount: 0,
      );
      final generatingVideo = _fairytale(
        format: 'video',
        status: 'GENERATING',
        pageCount: 2,
      );

      expect(generatingSlide.isPlayable, isFalse);
      expect(generatingVideo.isPlayable, isFalse);
      expect(generatingVideo.isVideoAssemblyFailed, isFalse);
    });

    test('status matching is exact and case sensitive', () {
      final lowerCase = _fairytale(
        format: 'slide',
        status: 'completed',
        pageCount: 3,
      );

      expect(lowerCase.isCompleted, isFalse);
      expect(lowerCase.isPlayable, isFalse);
    });
  });

  group('MyFairytale.fromJson defaults', () {
    test('missing format/status default to a playable slide', () {
      final fairytale = MyFairytale.fromJson({'id': 1, 'title': '기본값 동화'});

      expect(fairytale.format, 'slide');
      expect(fairytale.status, 'COMPLETED');
      expect(fairytale.pageCount, 0);
      expect(fairytale.isPlayable, isTrue);
    });

    test('parses the video assembly failure payload from the server', () {
      final fairytale = MyFairytale.fromJson({
        'id': 9,
        'title': '영상 합성 실패 동화',
        'format': 'video',
        'status': 'FAILED',
        'language': 'ko',
        'shared': false,
        'thumbnailUrl': null,
        'pageCount': 4,
      });

      expect(fairytale.isVideoAssemblyFailed, isTrue);
      expect(fairytale.isPlayable, isTrue);
    });
  });
}

MyFairytale _fairytale({
  required String format,
  required String status,
  required int pageCount,
}) {
  return MyFairytale(
    id: 1,
    title: '테스트 동화',
    format: format,
    status: status,
    language: 'ko',
    shared: false,
    pageCount: pageCount,
  );
}
