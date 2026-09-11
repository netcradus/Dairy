import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/core/utils/validators.dart';

void main() {
  group('Full Name Validation & Normalization Tests', () {
    test('Valid standard names should be accepted', () {
      expect(AppValidators.validateFullName('Hiba Khan'), isNull);
      expect(AppValidators.validateFullName('Akash Kumar'), isNull);
      expect(AppValidators.validateFullName('Hiba'), isNull);
      expect(AppValidators.validateFullName('Rahul Sharma'), isNull);
    });

    test(
        'Valid names with leading/trailing/multiple spaces should be accepted and normalized',
        () {
      expect(AppValidators.validateFullName('  Hiba Khan  '), isNull);
      expect(AppValidators.normalizeName('  Hiba Khan  '), equals('Hiba Khan'));

      expect(AppValidators.validateFullName('Hiba   Khan'), isNull);
      expect(AppValidators.normalizeName('Hiba   Khan'), equals('Hiba Khan'));
    });

    test('Names with digits should be rejected', () {
      expect(
        AppValidators.validateFullName('Hiba123'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('123456'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('Hiba123Khan'),
        equals('Name can contain letters and spaces only.'),
      );
    });

    test('Names with special characters and symbols should be rejected', () {
      expect(
        AppValidators.validateFullName('Hiba@'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('Hiba#'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('Hiba_Khan'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('@#\$%'),
        equals('Name can contain letters and spaces only.'),
      );
      expect(
        AppValidators.validateFullName('<>&'),
        equals('Name can contain letters and spaces only.'),
      );
    });

    test('Empty or whitespace-only names should be rejected', () {
      expect(
        AppValidators.validateFullName(''),
        equals('Please enter your full name.'),
      );
      expect(
        AppValidators.validateFullName('   '),
        equals('Please enter your full name.'),
      );
      expect(
        AppValidators.validateFullName(null),
        equals('Please enter your full name.'),
      );
    });

    test('Names shorter than 2 characters should be rejected', () {
      expect(
        AppValidators.validateFullName('A'),
        equals('Name must be at least 2 characters.'),
      );
      expect(
        AppValidators.validateFullName(' A '),
        equals('Name must be at least 2 characters.'),
      );
    });

    test('Names longer than 50 characters should be rejected', () {
      final longName = 'A' * 51;
      expect(
        AppValidators.validateFullName(longName),
        equals('Name cannot exceed 50 characters.'),
      );

      final valid50Name = 'A' * 50;
      expect(AppValidators.validateFullName(valid50Name), isNull);
    });
  });
}
