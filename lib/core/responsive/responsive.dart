import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Helper extension on [BuildContext] to easily query responsive state
extension ResponsiveContext on BuildContext {
  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Is mobile screen width (< 600)
  bool get isMobile => screenWidth < Breakpoints.tabletMin;

  /// Is tablet screen width (600 - 1024)
  bool get isTablet =>
      screenWidth >= Breakpoints.tabletMin &&
      screenWidth <= Breakpoints.tabletMax;

  /// Is desktop screen width (> 1024)
  bool get isDesktop => screenWidth > Breakpoints.tabletMax;

  /// Is large desktop screen width (>= 1440)
  bool get isLargeDesktop => screenWidth >= Breakpoints.desktopLargeMin;

  /// Active DeviceType
  DeviceType get deviceType {
    if (isDesktop) return DeviceType.desktop;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Get responsive grid column count
  int get responsiveGridColumns {
    if (screenWidth >= 1600) return 5;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 900) return 3;
    if (screenWidth >= 600) return 2;
    return 2; // 2 items per row on mobile grids
  }

  /// Get responsive horizontal padding
  double get responsiveHorizontalPadding {
    if (isDesktop) return 32.0;
    if (isTablet) return 24.0;
    return 16.0;
  }
}
