import 'package:intl/intl.dart';

/// Formatting Utility for Currency, Dates, and Units
abstract class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final NumberFormat _currencyDecimalFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  /// Format double to Indian Rupee (e.g. ₹65 or ₹65.50)
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _currencyDecimalFormat.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  /// Format date to readable string (e.g. 10 Aug 2026)
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Calculate discount percentage
  static int calculateDiscountPercentage(double originalPrice, double discountedPrice) {
    if (originalPrice <= 0 || discountedPrice >= originalPrice) return 0;
    return (((originalPrice - discountedPrice) / originalPrice) * 100).round();
  }
}
