import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDefaults {
  static double logoSize = 30.sp;
  static double defaultIconSize = 30.sp;
  static double defaultSmallFontSize = 14.sp;
  static double defaultFontSize = 16.sp;
  static double defaultTitleFontSize = 20.sp;
  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);
  static const kTextColor = Color(0xFF535353);
  static const kTextLightColor = Color(0xFFACACAC);

  static const kDefaultPaddin = 20.0;

  static const double radius = 15;
  static const double margin = 15;
  static const double padding = 15;

  /// Used For Border Radius
  static BorderRadius borderRadius = BorderRadius.circular(radius);

  /// Used For Bottom Sheet
  static BorderRadius bottomSheetRadius = const BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );

  /// Used For Top Sheet
  static BorderRadius topSheetRadius = const BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  /// Default Box Shadow used for containers
  static List<BoxShadow> boxShadow = [
    BoxShadow(
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 2),
      color: Colors.black.withValues(alpha: 0.04),
    ),
  ];

  static Duration duration = const Duration(milliseconds: 300);

  static const String rupeeSymbol = '₹';
}
