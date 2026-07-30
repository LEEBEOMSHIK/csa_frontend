import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';

/// `hasVideo`는 재생기에 넘길 URL의 신뢰 경계다.
/// http/https만 허용하는 scheme 화이트리스트가 무너지면 서버가 준 임의 scheme
/// 문자열이 그대로 플레이어로 전달된다.
void main() {
  group('FairytaleGenerateResponse.hasVideo', () {
    test('null videoUrl means there is no video', () {
      expect(_response(videoUrl: null).hasVideo, isFalse);
    });

    test('empty or blank videoUrl means there is no video', () {
      expect(_response(videoUrl: '').hasVideo, isFalse);
      expect(_response(videoUrl: '   ').hasVideo, isFalse);
    });

    test('a non-URL string is rejected', () {
      expect(_response(videoUrl: 'not a url').hasVideo, isFalse);
    });

    test('a scheme-less URL is rejected', () {
      expect(_response(videoUrl: 'example.com/a.mp4').hasVideo, isFalse);
      expect(_response(videoUrl: '/media/a.mp4').hasVideo, isFalse);
    });

    test('schemes outside the http/https allowlist are rejected', () {
      expect(_response(videoUrl: 'ftp://example.com/a.mp4').hasVideo, isFalse);
      expect(_response(videoUrl: 'file:///tmp/a.mp4').hasVideo, isFalse);
      expect(_response(videoUrl: 'javascript:alert(1)').hasVideo, isFalse);
    });

    test('http and https URLs are accepted', () {
      expect(_response(videoUrl: 'https://example.com/a.mp4').hasVideo, isTrue);
      expect(_response(videoUrl: 'http://example.com/a.mp4').hasVideo, isTrue);
    });

    test('surrounding whitespace is trimmed before validation', () {
      expect(
        _response(videoUrl: '  https://example.com/a.mp4  ').hasVideo,
        isTrue,
      );
    });
  });

  group('FairytaleGenerateResponse.hasSlides', () {
    test('an empty page list means there are no slides', () {
      expect(_response(pages: const []).hasSlides, isFalse);
    });

    test('a non-empty page list means slides are playable', () {
      final response = _response(
        pages: const [FairytalePageResponse(pageIndex: 1, text: '첫 페이지')],
      );

      expect(response.hasSlides, isTrue);
    });

    test('video assembly failure still leaves slides playable', () {
      // 백엔드는 영상 합성이 실패하면 videoUrl을 null로 두고 pages만 내려준다.
      final response = _response(
        videoUrl: null,
        pages: const [FairytalePageResponse(pageIndex: 1, text: '첫 페이지')],
      );

      expect(response.hasVideo, isFalse);
      expect(response.hasSlides, isTrue);
    });
  });

  group('FairytaleGenerateResponse.fromJson', () {
    test('missing videoUrl parses as a slide-only response', () {
      final response = FairytaleGenerateResponse.fromJson({
        'id': 7,
        'title': '별빛 모험',
        'pages': [
          {'pageIndex': 1, 'text': '첫 페이지'},
        ],
      });

      expect(response.language, 'ko');
      expect(response.voiceType, 'dad');
      expect(response.hasVideo, isFalse);
      expect(response.hasSlides, isTrue);
    });
  });
}

FairytaleGenerateResponse _response({
  String? videoUrl,
  List<FairytalePageResponse> pages = const [
    FairytalePageResponse(pageIndex: 1, text: '첫 페이지'),
  ],
}) {
  return FairytaleGenerateResponse(
    id: 1,
    title: '테스트 동화',
    pages: pages,
    videoUrl: videoUrl,
  );
}
