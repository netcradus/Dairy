import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/main_layout/main_layout_screen.dart';

void main() {
  testWidgets('MainLayout desktop viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: MainLayoutScreen()),
      ),
    );
    await tester.pumpAndSettle();
    debugPrint('DONE - no exceptions');
  });
}
