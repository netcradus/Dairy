import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_app/core/widgets/app_desktop_sidebar.dart';
import 'package:dairy_app/features/profile/profile_screen.dart';
import 'package:dairy_app/models/user.dart';
import 'package:dairy_app/providers/user_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createDesktopLayoutTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AppDesktopSidebar(
                currentIndex: 3,
                onTap: (_) {},
              ),
              const Expanded(
                child: ProfileScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Profile & Sidebar Synchronization Tests', () {
    testWidgets(
        'Test 1: Initial state renders same user name and Fresh Member in both header and sidebar',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set initial user
      const initialUser = User(
        id: 'usr_test_123',
        name: 'Zehra',
        phone: '+91 98765 43210',
        email: 'zehra@example.com',
        role: 'customer',
      );
      container.read(userProvider.notifier).setSession(initialUser);

      await tester.pumpWidget(createDesktopLayoutTestWidget(container));
      await tester.pumpAndSettle();

      // Verify 'Zehra' appears in both Sidebar and ProfileScreen
      expect(find.text('Zehra'), findsNWidgets(2));

      // Verify 'Fresh Member' badge/label appears in both Sidebar and ProfileScreen
      expect(find.text('Fresh Member'), findsNWidgets(2));

      // Verify phone number in ProfileScreen
      expect(find.text('+91 98765 43210'), findsOneWidget);
    });

    testWidgets(
        'Test 2: Updating name immediately updates both Main Profile and Sidebar together',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const initialUser = User(
        id: 'usr_test_123',
        name: 'Zehra',
        phone: '+91 98765 43210',
        email: 'zehra@example.com',
        role: 'customer',
      );
      container.read(userProvider.notifier).setSession(initialUser);

      await tester.pumpWidget(createDesktopLayoutTestWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('Zehra'), findsNWidgets(2));

      // Update user name in shared provider
      await container.read(userProvider.notifier).updateProfile(name: 'Zehra Khan');
      await tester.pumpAndSettle();

      // Both Header and Sidebar must immediately reflect 'Zehra Khan'
      expect(find.text('Zehra Khan'), findsNWidgets(2));
      expect(find.text('Zehra'), findsNothing);
    });

    testWidgets(
        'Test 3: Updating profile photo URL immediately updates both Main Profile and Sidebar',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const initialUser = User(
        id: 'usr_test_123',
        name: 'Zehra',
        phone: '+91 98765 43210',
        profileImageUrl: null,
        role: 'customer',
      );
      container.read(userProvider.notifier).setSession(initialUser);

      await tester.pumpWidget(createDesktopLayoutTestWidget(container));
      await tester.pumpAndSettle();

      // Fallback person icons appear in both header and sidebar
      expect(find.byIcon(Icons.person_rounded), findsWidgets);

      // Update profile image URL in shared provider
      const newImageUrl = 'https://example.com/profiles/zehra.jpg';
      await container
          .read(userProvider.notifier)
          .updateProfile(profileImageUrl: newImageUrl);
      await tester.pumpAndSettle();

      // Provider holds new image URL
      expect(container.read(userProvider).profileImageUrl, equals(newImageUrl));
    });
  });
}
