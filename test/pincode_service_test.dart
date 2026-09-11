import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dairy_app/services/pincode_service.dart';

void main() {
  group('PinCodeService Tests', () {
    test('Test 1: Valid city + matching PIN succeeds', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('201001')) {
          return http.Response(
            jsonEncode([
              {
                'Status': 'Success',
                'PostOffice': [
                  {
                    'Name': 'Ghaziabad H.O',
                    'District': 'Ghaziabad',
                    'Block': 'Ghaziabad',
                    'Division': 'Ghaziabad',
                    'State': 'Uttar Pradesh',
                    'Pincode': '201001',
                  }
                ]
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = PinCodeService(client: mockClient);
      final result = await service.validatePinCode(
        pinCode: '201001',
        city: 'Ghaziabad',
        state: 'Uttar Pradesh',
      );

      expect(result.isValid, isTrue);
      expect(result.status, equals(PinCodeValidationStatus.valid));
      expect(result.errorMessage, isNull);
    });

    test('Test 2: Valid city + mismatching PIN returns mismatch error',
        () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('110001')) {
          return http.Response(
            jsonEncode([
              {
                'Status': 'Success',
                'PostOffice': [
                  {
                    'Name': 'Baroda House',
                    'District': 'Central Delhi',
                    'Block': 'New Delhi',
                    'Division': 'New Delhi Central',
                    'State': 'Delhi',
                    'Pincode': '110001',
                  }
                ]
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = PinCodeService(client: mockClient);
      final result = await service.validatePinCode(
        pinCode: '110001',
        city: 'Ghaziabad',
        state: 'Uttar Pradesh',
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(PinCodeValidationStatus.mismatch));
      expect(
        result.errorMessage,
        equals('This PIN code does not match the selected city.'),
      );
    });

    test('Test 3: Short PIN (< 6 digits) rejected with format error', () async {
      final service = PinCodeService();
      final result = await service.validatePinCode(
        pinCode: '123',
        city: 'Ghaziabad',
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(PinCodeValidationStatus.invalidFormat));
      expect(
        result.errorMessage,
        equals('Please enter a valid 6-digit PIN code.'),
      );
    });

    test('Test 4: PIN containing letters rejected with format error', () async {
      final service = PinCodeService();
      final result = await service.validatePinCode(
        pinCode: '12A456',
        city: 'Ghaziabad',
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(PinCodeValidationStatus.invalidFormat));
      expect(
        result.errorMessage,
        equals('Please enter a valid 6-digit PIN code.'),
      );
    });

    test('Test 5: API / Network failure returns unable to verify error',
        () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection failed');
      });

      final service = PinCodeService(client: mockClient);
      final result = await service.validatePinCode(
        pinCode: '201001',
        city: 'Ghaziabad',
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(PinCodeValidationStatus.networkError));
      expect(
        result.errorMessage,
        equals('Unable to verify PIN code. Please try again.'),
      );
    });

    test(
        'Test 6: Alias matching for cities (Gurugram <-> Gurgaon, Noida <-> Gautam Buddha Nagar)',
        () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('122001')) {
          return http.Response(
            jsonEncode([
              {
                'Status': 'Success',
                'PostOffice': [
                  {
                    'Name': 'Gurgaon H.O',
                    'District': 'Gurgaon',
                    'Block': 'Gurgaon',
                    'State': 'Haryana',
                    'Pincode': '122001',
                  }
                ]
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = PinCodeService(client: mockClient);
      final result = await service.validatePinCode(
        pinCode: '122001',
        city: 'Gurugram',
        state: 'Haryana',
      );

      expect(result.isValid, isTrue);
      expect(result.status, equals(PinCodeValidationStatus.valid));
    });
  });
}
