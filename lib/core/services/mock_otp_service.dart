import 'dart:async';
import 'dart:math';

/// A clearly separated Mock OTP Service for testing.
/// This is designed so it can be easily replaced by Firebase Auth or a custom OTP API.
class MockOtpService {
  // In-memory cache to store generated OTPs for each mobile number
  final Map<String, String> _otpCache = {};
  
  // Stream controller to broadcast OTPs for visual testing or debug logs
  final _otpStreamController = StreamController<MockOtpNotification>.broadcast();
  Stream<MockOtpNotification> get otpStream => _otpStreamController.stream;

  /// Sends a 6-digit OTP to the specified mobile number.
  /// Generates a random OTP, stores it in memory, and prints/broadcasts it.
  Future<bool> sendOtp(String mobileNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    String otp;
    if (mobileNumber == '9999999999' || mobileNumber == '8888888888' || mobileNumber == '7777777777') {
      // Fixed OTP for easy automated testing/manual demo testing
      otp = '123456';
    } else {
      // Generate a random 6-digit OTP
      final random = Random();
      otp = (100000 + random.nextInt(900000)).toString();
    }

    _otpCache[mobileNumber] = otp;

    // Log to console so the tester/developer can see it
    print('--------- MOCK OTP SERVICE ---------');
    print('Mobile Number: $mobileNumber');
    print('Generated OTP: $otp');
    print('------------------------------------');

    // Broadcast the OTP so UI can optionally show a toast/overlay for debugging ease
    _otpStreamController.add(MockOtpNotification(
      mobileNumber: mobileNumber,
      otp: otp,
    ));

    return true;
  }

  /// Verifies if the entered OTP is correct for the given mobile number.
  Future<bool> verifyOtp(String mobileNumber, String enteredOtp) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final cachedOtp = _otpCache[mobileNumber];
    if (cachedOtp != null && cachedOtp == enteredOtp) {
      // Clear OTP after successful verification
      _otpCache.remove(mobileNumber);
      return true;
    }
    
    // For demo convenience, also accept '123456' universally if no OTP was sent yet
    if (enteredOtp == '123456') {
      return true;
    }

    return false;
  }
}

class MockOtpNotification {
  final String mobileNumber;
  final String otp;

  MockOtpNotification({required this.mobileNumber, required this.otp});
}
