import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/character/models/saved_character.dart';
import 'package:csa_frontend/features/character/screens/character_screen.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';

void main() {
  testWidgets('shows a game-style item shelf on the all tab', (tester) async {
    await _pumpCharacterScreen(tester);

    expect(find.byKey(const ValueKey('character-game-stage')), findsOneWidget);
    expect(find.byKey(const ValueKey('character-option-grid')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('character-option-cell-hat-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('character-option-cell-top-1')),
      findsOneWidget,
    );

    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('character-option-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });

  testWidgets('keeps the option grid at four columns on 430px mobile', (
    tester,
  ) async {
    await _pumpCharacterScreen(tester, surfaceSize: const Size(430, 932));

    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('character-option-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    final gridRect = tester.getRect(
      find.byKey(const ValueKey('character-option-grid')),
    );
    const screenRight = 430.0;

    expect(delegate.crossAxisCount, 4);
    expect(gridRect.right, lessThanOrEqualTo(screenRight));
    expect(screenRight - gridRect.right, greaterThanOrEqualTo(24));
  });

  testWidgets('selects accessory options from the preview side hit zone', (
    tester,
  ) async {
    await _pumpCharacterScreen(tester, surfaceSize: const Size(430, 932));

    final stageRect = tester.getRect(
      find.byKey(const ValueKey('character-game-stage')),
    );

    await tester.tapAt(Offset(stageRect.left + 32, stageRect.top + 188));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('character-option-cell-accessory-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('character-option-cell-bottom-1')),
      findsNothing,
    );
  });

  testWidgets('keeps the character label below the Flame stage', (
    tester,
  ) async {
    await _pumpCharacterScreen(tester);

    final stageRect = tester.getRect(
      find.byKey(const ValueKey('character-game-stage')),
    );
    final labelRect = tester.getRect(find.text('나의 캐릭터'));

    expect(labelRect.top, greaterThanOrEqualTo(stageRect.bottom));
  });

  testWidgets('marks an equipped item with a selected badge', (tester) async {
    await _pumpCharacterScreen(tester);

    const optionKey = ValueKey('character-option-cell-hat-1');
    const badgeKey = ValueKey('character-selected-badge-hat-1');

    expect(find.byKey(badgeKey), findsNothing);

    await tester.tap(find.byKey(optionKey));
    await tester.pump();

    expect(find.byKey(badgeKey), findsOneWidget);
  });
}

Future<void> _pumpCharacterScreen(
  WidgetTester tester, {
  Size? surfaceSize,
}) async {
  if (surfaceSize != null) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = surfaceSize;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('ko'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ko'), Locale('ja')],
      home: CharacterScreen(fetchCharacters: _emptyCharacters),
    ),
  );
  await tester.pump();
}

Future<List<SavedCharacter>> _emptyCharacters() async => [];
