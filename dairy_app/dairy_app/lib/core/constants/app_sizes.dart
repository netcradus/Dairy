import 'package:flutter/material.dart';

/// Sawariya Dairy Spacing and Dimension Tokens
abstract class AppSizes {
  // Spacing Tokens
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p14 = 14.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;

  // Border Radius Tokens (Prefer 12-20px)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusFull = 999.0;
  static const double radiusCapsule = 24.0;

  // Border Radius Objects
  static const BorderRadius borderSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderXLarge = BorderRadius.all(Radius.circular(radiusXLarge));
  static const BorderRadius borderCapsule = BorderRadius.all(Radius.circular(radiusCapsule));

  // Padding Objects
  static const EdgeInsets paddingMobileHorizontal = EdgeInsets.symmetric(horizontal: p16);
  static const EdgeInsets paddingDesktopHorizontal = EdgeInsets.symmetric(horizontal: p32);
  static const EdgeInsets paddingCard = EdgeInsets.all(p16);
  static const EdgeInsets paddingCardCompact = EdgeInsets.all(p12);

  // Component Heights & Widths
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double inputHeight = 52.0;
  static const double desktopSidebarWidth = 260.0;
  static const double desktopSidebarCollapsedWidth = 80.0;
  static const double maxContentWidthDesktop = 1280.0;
}
