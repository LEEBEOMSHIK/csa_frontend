import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/fairytale_create/screens/fairytale_slide_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/audio_narration_service.dart';

Widget _wrap(FairytaleGenerateResponse response) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ko'), Locale('ja')],
    home: FairytaleSlideScreen(
      fairytale: response,
      lang: 'ko',
      voiceType: 'dad',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // flutter_tts / just_audio 플랫폼 채널을 테스트 환경에서 무력화한다.
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    // flutter_tts 채널은 테스트 환경에서 무력화한다.
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => 1,
    );
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      null,
    );
    AudioNarrationService.instance.playOverride = null;
    AudioNarrationService.instance.stopOverride = null;
  });

  testWidgets('shows generated pages and moves between slides', (tester) async {
    final response = FairytaleGenerateResponse(
      id: 1,
      title: '별빛 모험',
      pages: const [
        FairytalePageResponse(pageIndex: 1, text: '첫 번째 페이지입니다.'),
        FairytalePageResponse(pageIndex: 2, text: '두 번째 페이지입니다.'),
      ],
    );

    await tester.pumpWidget(_wrap(response));

    expect(find.text('별빛 모험'), findsOneWidget);
    expect(find.text('첫 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('slide-next-button')));
    await tester.pumpAndSettle();

    expect(find.text('두 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('slide-prev-button')));
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 페이지입니다.'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('plays server audioUrl first when available', (tester) async {
    final l10nKo = await AppLocalizations.delegate.load(const Locale('ko'));
    final playedUrls = <String>[];
    AudioNarrationService.instance.playOverride = (url) async {
      playedUrls.add(url);
      return true; // 서버 오디오 재생 성공
    };

    final response = FairytaleGenerateResponse(
      id: 3,
      title: '서버 오디오',
      pages: const [
        FairytalePageResponse(
          pageIndex: 1,
          text: '서버 오디오 페이지입니다.',
          audioUrl: 'https://cdn.example.com/page_1.mp3',
        ),
      ],
    );

    await tester.pumpWidget(_wrap(response));

    await tester.tap(find.byKey(const Key('slide-play-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // 서버 audioUrl 이 우선 재생되었고, 재생 상태(정지 라벨)로 전환된다.
    expect(playedUrls, ['https://cdn.example.com/page_1.mp3']);
    expect(find.text(l10nKo.detailDownloadCancel), findsOneWidget);
  });

  testWidgets('falls back to TTS when server audio playback fails',
      (tester) async {
    final l10nKo = await AppLocalizations.delegate.load(const Locale('ko'));
    var playAttempts = 0;
    AudioNarrationService.instance.playOverride = (url) async {
      playAttempts++;
      return false; // 서버 오디오 재생 실패
    };

    final response = FairytaleGenerateResponse(
      id: 2,
      title: '소리 모험',
      pages: const [
        FairytalePageResponse(
          pageIndex: 1,
          text: '오디오가 있는 페이지입니다.',
          audioUrl: 'https://cdn.example.com/page_1.mp3',
        ),
      ],
    );

    await tester.pumpWidget(_wrap(response));

    expect(find.text(l10nKo.detailReadBtn), findsOneWidget);

    await tester.tap(find.byKey(const Key('slide-play-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // 서버 오디오 재생을 시도했고 실패 → TTS fallback 으로 재생 상태가 된다.
    expect(playAttempts, 1);
    expect(find.text(l10nKo.detailDownloadCancel), findsOneWidget);

    // 다시 토글하면 정지되어 재생 라벨로 복귀한다.
    await tester.tap(find.byKey(const Key('slide-play-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10nKo.detailReadBtn), findsOneWidget);
  });
}
