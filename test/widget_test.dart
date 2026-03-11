import 'package:flutter_test/flutter_test.dart';
import 'package:csa_frontend/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FairyTaleApp());
    expect(find.byType(FairyTaleApp), findsOneWidget);
  });
}
