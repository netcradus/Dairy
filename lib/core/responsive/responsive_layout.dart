import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'responsive.dart';

/// Centralized ResponsiveLayout Builder Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > Breakpoints.tabletMax) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Breakpoints.tabletMin) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}

/// Mobile Specific Layout Shell Widget
class MobileLayout extends StatelessWidget {
  final Widget child;
  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return context.isMobile ? child : const SizedBox.shrink();
  }
}

/// Tablet Specific Layout Shell Widget
class TabletLayout extends StatelessWidget {
  final Widget child;
  const TabletLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return context.isTablet ? child : const SizedBox.shrink();
  }
}

/// Desktop Specific Layout Shell Widget
class DesktopLayout extends StatelessWidget {
  final Widget child;
  const DesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return context.isDesktop ? child : const SizedBox.shrink();
  }
}

/// Responsive Centered Content Container with Maximum Width Constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1280.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
        );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
