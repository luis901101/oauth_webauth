import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Drains the delayed code verifier check scheduled in initState.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('OAuth WebAuth samples'), findsOneWidget);
    expect(find.text('OAuth login samples'), findsOneWidget);
    expect(find.text('Base redirect samples'), findsOneWidget);
  });
}
