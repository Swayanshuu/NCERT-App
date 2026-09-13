import 'package:flutter/material.dart';

enum ScreenType { mobileSmall, mobile, tablet, desktop, desktopLarge }

class AppResponsive {
  static const double breakpointMobileSmall = 380.0;
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktopLarge = 1440.0;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobileSmall) return ScreenType.mobileSmall;
    if (width < breakpointMobile) return ScreenType.mobile;
    if (width < breakpointTablet) return ScreenType.tablet;
    if (width < breakpointDesktopLarge) return ScreenType.desktop;
    return ScreenType.desktopLarge;
  }

  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointTablet;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet;
  }

  static bool isDesktopLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointDesktopLarge;
  }

  static int getGridColumnCount(BuildContext context, {double? availableWidth}) {
    final width = availableWidth ?? MediaQuery.of(context).size.width;
    if (width < 380) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1600) return 1280.0;
    if (width > 1200) return 1100.0;
    return double.infinity;
  }
}

class MaxContentConstraint extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const MaxContentConstraint({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxWidth ?? AppResponsive.getMaxContentWidth(context);

    if (effectiveMax == double.infinity) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMax),
        child: child,
      ),
    );
  }
}
