import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet }

class AppResponsive {
  static const double breakpointMobile = 600.0;
  static const double maxTabletContentWidth = 840.0;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) return ScreenType.mobile;
    return ScreenType.tablet;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointMobile;
  }

  // Deprecated desktop helper redirects to tablet for backward-compat
  static bool isDesktop(BuildContext context) => false;

  static int getGridColumnCount(BuildContext context, {double? availableWidth}) {
    final width = availableWidth ?? MediaQuery.of(context).size.width;
    if (width < 340) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointMobile) return maxTabletContentWidth;
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
