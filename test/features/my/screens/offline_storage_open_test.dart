import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/screens/offline_storage_screen.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';

OfflineSlideEntry _slide(List<Map<String, String>> pageAudio) {
  return OfflineSlideEntry(
    fairytaleId: '7',
    title: '저장된 동화',
    thumbnailLocalPath: '',
    pages: [
      for (var i = 0; i < pageAudio.length; i++)
        OfflineSlidePage(
          pageIndex: i + 1,
          text: '페이지',
          localImagePath: '',
          localAudioPaths: pageAudio[i],
        ),
    ],
    downloadedAt: DateTime.now(),
  );
}

void main() {
  group('restoreOfflineVoiceLang', () {
    test('restores voice/lang from stored audio key (dad_ja)', () {
      final r = restoreOfflineVoiceLang(
        _slide([
          {'dad_ja': '/tmp/p1.mp3'},
        ]),
      );
      expect(r.voiceType, 'dad');
      expect(r.language, 'ja');
    });

    test('restores non-default voice (mom_ko)', () {
      final r = restoreOfflineVoiceLang(
        _slide([
          {'mom_ko': '/tmp/p1.mp3'},
        ]),
      );
      expect(r.voiceType, 'mom');
      expect(r.language, 'ko');
    });

    test('uses first page that has an audio key', () {
      final r = restoreOfflineVoiceLang(
        _slide([
          {},
          {'dad_ja': '/tmp/p2.mp3'},
        ]),
      );
      expect(r.voiceType, 'dad');
      expect(r.language, 'ja');
    });

    test('voice containing underscore splits on last underscore', () {
      final r = restoreOfflineVoiceLang(
        _slide([
          {'grand_dad_ja': '/tmp/p1.mp3'},
        ]),
      );
      expect(r.voiceType, 'grand_dad');
      expect(r.language, 'ja');
    });

    test('falls back to dad/ko when no audio key', () {
      final r = restoreOfflineVoiceLang(_slide([{}]));
      expect(r.voiceType, 'dad');
      expect(r.language, 'ko');
    });
  });
}
