// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/main.dart';

void main() {
  testWidgets('Splash screen shows Sawariya Dairy title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the splash screen shows 'Sawariya Dairy'.
    expect(find.text('Sawariya Dairy'), findsOneWidget);

    // Pump to let the navigation timer run its course.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
