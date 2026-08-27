/// Centralized Responsive Breakpoints for Sawariya Dairy
abstract class Breakpoints {
  /// Mobile screen width threshold (< 600px)
  static const double mobileMax = 599.9;

  /// Tablet screen min width (600px)
  static const double tabletMin = 600.0;

  /// Tablet screen max width (900px)
  static const double tabletMax = 899.9;

  /// Desktop screen min width (> 900px)
  static const double desktopMin = 900.0;

  /// Large Desktop min width (1440px)
  static const double desktopLargeMin = 1440.0;
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}
