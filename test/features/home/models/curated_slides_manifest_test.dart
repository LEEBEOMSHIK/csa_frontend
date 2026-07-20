import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/home/models/curated_slides_manifest.dart';

void main() {
  test('parses a curated manifest with localized media and placement', () {
    final manifest = CuratedSlidesManifest.fromJson({
      'fairytaleId': 12,
      'contentVersion': '2026-07-20.1',
      'characterSupported': true,
      'characterRenderMode': 'LOCAL_OVERLAY',
      'pages': [
        {
          'pageIndex': 1,
          'imageUrl': 'https://cdn.example/page-1.png',
          'text': {'ko': '한국어 본문', 'ja': '日本語の本文'},
          'audioUrls': {
            'dad': {
              'ko': 'https://cdn.example/dad-ko.mp3',
              'ja': 'https://cdn.example/dad-ja.mp3',
            },
          },
          'characterPlacement': {
            'x': 0.18,
            'y': 0.42,
            'width': 0.24,
            'height': 0.36,
            'zIndex': 2,
            'pose': 'standing',
            'flipX': false,
          },
        },
      ],
    });

    final page = manifest.pages.single;
    expect(manifest.contentVersion, '2026-07-20.1');
    expect(page.text.forLocale('ja'), '日本語の本文');
    expect(
      page.audioUrlFor(voiceType: 'dad', locale: 'ko'),
      'https://cdn.example/dad-ko.mp3',
    );
    expect(page.audioUrlFor(voiceType: 'mom', locale: 'ko'), isNull);
    expect(page.characterPlacement?.width, 0.24);
    expect(page.characterPlacement?.flipX, isFalse);
  });

  test(
    'keeps character placement null when a curated page does not support it',
    () {
      final page = CuratedSlidePage.fromJson({
        'pageIndex': 1,
        'imageUrl': 'https://cdn.example/page-1.png',
        'text': {'ko': '본문', 'ja': '本文'},
        'audioUrls': {},
        'characterPlacement': null,
      });

      expect(page.characterPlacement, isNull);
      expect(page.audioUrlFor(voiceType: 'dad', locale: 'ko'), isNull);
    },
  );

  test('ignores malformed or out-of-bounds character placement', () {
    final malformed = CuratedSlidePage.fromJson({
      'pageIndex': 1,
      'imageUrl': 'https://cdn.example/page-1.png',
      'text': {'ko': '본문', 'ja': '本文'},
      'audioUrls': {},
      'characterPlacement': {'x': 'left'},
    });
    final outOfBounds = CuratedSlidePage.fromJson({
      'pageIndex': 2,
      'imageUrl': 'https://cdn.example/page-2.png',
      'text': {'ko': '본문', 'ja': '本文'},
      'audioUrls': {},
      'characterPlacement': {
        'x': 0.9,
        'y': 0.2,
        'width': 0.2,
        'height': 0.3,
        'zIndex': 0,
        'pose': 'standing',
        'flipX': false,
      },
    });

    expect(malformed.characterPlacement, isNull);
    expect(
      outOfBounds.characterPlacement?.isRenderableStandingOverlay,
      isFalse,
    );
  });

  test('accepts only standing placements for the current renderer', () {
    final page = CuratedSlidePage.fromJson({
      'pageIndex': 1,
      'imageUrl': 'https://cdn.example/page-1.png',
      'text': {'ko': '본문', 'ja': '本文'},
      'audioUrls': {},
      'characterPlacement': {
        'x': 0.1,
        'y': 0.2,
        'width': 0.2,
        'height': 0.3,
        'zIndex': 0,
        'pose': 'running',
        'flipX': false,
      },
    });

    expect(page.characterPlacement?.isRenderableStandingOverlay, isFalse);
  });
}
