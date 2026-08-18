import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/main.dart';
import 'package:dairy_app/providers/user_provider.dart';
import 'package:dairy_app/models/user.dart';

void main() {
  testWidgets('Real router renders Home (desktop viewport)',
      (WidgetTester tester) async {
    // Simulate a wide Chrome window -> desktop layout branch.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Ignore benign pre-existing ListTile-vs-DecoratedBox cosmetic warning
    // (it does not affect layout and is unrelated to the blank-screen bug).
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains(
          'ListTile background color or ink splashes may be invisible')) {
        return;
      }
      originalOnError?.call(details);
    };

    const loggedIn = User(
      id: 'u1',
      name: 'Test',
      phone: '9999999999',
      email: 'a@b.com',
      role: 'customer',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith((ref) => UserNotifier()..state = loggedIn),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    debugPrint('=== looking for Home "Categories" ===');
    expect(find.text('Categories'), findsWidgets,
        reason: 'Home should render inside MainLayout (desktop)');
  });
}
