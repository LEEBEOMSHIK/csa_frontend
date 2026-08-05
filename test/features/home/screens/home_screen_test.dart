import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/home/models/fairytale.dart';
import 'package:csa_frontend/features/home/models/fairytale_category.dart';
import 'package:csa_frontend/features/home/screens/home_screen.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

Widget _wrap(Widget child, Locale locale) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ko'), Locale('ja')],
    home: child,
  );
}

void main() {
  tearDown(() {
    localeNotifier.value = const Locale('ko');
  });

  testWidgets('renders home catalog data returned by the API service', (
    tester,
  ) async {
    final service = _FakeHomeCatalogService(data: _homeData());
    localeNotifier.value = const Locale('ko');

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    expect(find.text('#모험'), findsOneWidget);
    expect(find.text('여름 이야기'), findsOneWidget);
    expect(find.text('새 동화'), findsOneWidget);
    expect(find.text('추천 동화'), findsOneWidget);
    expect(service.requestedLanguages, ['ko']);
    expect(service.requestedCategories, [null]);
  });

  testWidgets('shows loading while the home catalog request is pending', (
    tester,
  ) async {
    final completer = Completer<HomePageData>();
    final service = _PendingHomeCatalogService(completer.future);

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_homeData());
    await tester.pumpAndSettle();

    expect(find.text('여름 이야기'), findsOneWidget);
  });

  testWidgets('still renders home data when categories fail', (tester) async {
    final service = _FakeHomeCatalogService(
      data: _homeData(),
      failCategories: true,
    );

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    expect(find.text('여름 이야기'), findsOneWidget);
    expect(find.text('동화를 불러오지 못했어요'), findsNothing);
  });

  testWidgets('uses Japanese API content for Japanese locale', (tester) async {
    final service = _FakeHomeCatalogService(data: _homeData());
    localeNotifier.value = const Locale('ja');

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ja')),
    );
    await tester.pumpAndSettle();

    expect(find.text('#ぼうけん'), findsOneWidget);
    expect(find.text('夏のおはなし'), findsOneWidget);
    expect(find.text('여름 이야기'), findsNothing);
    expect(find.text('#해변'), findsNothing);
    expect(service.requestedLanguages, ['ja']);
  });

  testWidgets('shows an empty state for an empty home catalog', (tester) async {
    final service = _FakeHomeCatalogService(
      data: const HomePageData(themes: [], newItems: [], recommended: []),
    );

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    expect(find.text('아직 동화가 없어요'), findsOneWidget);
  });

  testWidgets('shows an error state and retries the home request', (
    tester,
  ) async {
    final service = _FakeHomeCatalogService(data: _homeData(), fail: true);

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    expect(find.text('동화를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);

    service.fail = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('여름 이야기'), findsOneWidget);
    expect(service.requestedLanguages, ['ko', 'ko']);
  });

  testWidgets('reloads the home catalog when a category is selected', (
    tester,
  ) async {
    final service = _FakeHomeCatalogService(data: _homeData());

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('#모험'));
    await tester.pumpAndSettle();

    expect(service.requestedCategories, [null, 'adventure']);
  });

  testWidgets('ignores an older home response after a newer request', (
    tester,
  ) async {
    final service = _RaceHomeCatalogService();

    await tester.pumpWidget(
      _wrap(HomeScreen(service: service), const Locale('ko')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('#모험'));
    await tester.pump();
    await tester.tap(find.text('#모험'));
    await tester.pump();

    service.newer.complete(_homeDataWithTitle('최신 동화'));
    await tester.pump();
    service.older.complete(_homeDataWithTitle('이전 동화'));
    await tester.pumpAndSettle();

    expect(find.text('최신 동화'), findsOneWidget);
    expect(find.text('이전 동화'), findsNothing);
  });
}

HomePageData _homeData() {
  return const HomePageData(
    themes: [
      FairytaleItem(
        id: 1,
        title: '여름 이야기',
        titleJa: '夏のおはなし',
        themeTag: '#해변',
        categories: ['adventure'],
      ),
    ],
    newItems: [
      FairytaleItem(
        id: 2,
        title: '새 동화',
        titleJa: '新しいどうわ',
        categories: ['adventure'],
      ),
    ],
    recommended: [
      FairytaleItem(
        id: 3,
        title: '추천 동화',
        titleJa: 'おすすめのどうわ',
        categories: ['adventure'],
      ),
    ],
  );
}

HomePageData _homeDataWithTitle(String title) {
  return HomePageData(
    themes: [FairytaleItem(id: 1, title: title, categories: const [])],
    newItems: const [],
    recommended: const [],
  );
}

class _FakeHomeCatalogService implements HomeCatalogService {
  _FakeHomeCatalogService({
    required this.data,
    this.fail = false,
    this.failCategories = false,
  });

  final HomePageData data;
  bool fail;
  final bool failCategories;
  final List<String?> requestedCategories = [];
  final List<String?> requestedLanguages = [];

  @override
  Future<List<FairytaleCategory>> getCategories() async {
    if (failCategories) {
      throw StateError('category request failed');
    }
    return const [
      FairytaleCategory(
        categoryKey: 'adventure',
        nameKo: '모험',
        nameJa: 'ぼうけん',
        count: 1,
      ),
    ];
  }

  @override
  Future<HomePageData> getHomePage({String? categoryKey, String? lang}) async {
    requestedCategories.add(categoryKey);
    requestedLanguages.add(lang);
    if (fail) {
      throw StateError('home request failed');
    }
    return data;
  }
}

class _PendingHomeCatalogService implements HomeCatalogService {
  const _PendingHomeCatalogService(this.homeFuture);

  final Future<HomePageData> homeFuture;

  @override
  Future<List<FairytaleCategory>> getCategories() async => const [];

  @override
  Future<HomePageData> getHomePage({String? categoryKey, String? lang}) {
    return homeFuture;
  }
}

class _RaceHomeCatalogService implements HomeCatalogService {
  final Completer<HomePageData> older = Completer<HomePageData>();
  final Completer<HomePageData> newer = Completer<HomePageData>();
  int _requestCount = 0;

  @override
  Future<List<FairytaleCategory>> getCategories() async {
    return const [
      FairytaleCategory(
        categoryKey: 'adventure',
        nameKo: '모험',
        nameJa: 'ぼうけん',
        count: 1,
      ),
    ];
  }

  @override
  Future<HomePageData> getHomePage({String? categoryKey, String? lang}) {
    _requestCount++;
    return switch (_requestCount) {
      1 => Future<HomePageData>.value(_homeData()),
      2 => older.future,
      _ => newer.future,
    };
  }
}
