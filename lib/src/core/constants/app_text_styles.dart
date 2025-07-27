import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';

class AppTextStyle {
  // Reusable builder methods
  static TextStyle poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.black333333Color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle rosario({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.black333333Color,
  }) {
    return GoogleFonts.rosario(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ==== New Recommended Styles ====

  // Poppins
  static final TextStyle poppinsBold17 = poppins(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle poppinsBold16 = poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle poppinsRegular14 = poppins(fontSize: 14);
  static final TextStyle poppinsRegular16 = poppins(fontSize: 16);
  static final TextStyle poppinsRegular18 = poppins(fontSize: 18);
  static final TextStyle poppinsRegular20 = poppins(fontSize: 20);
  static final TextStyle poppinsTitle22 = poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle poppinsButtonWhite16 = poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static final TextStyle poppinsHint16 = poppins(
    fontSize: 16,
    color: Colors.grey,
  );
  static final TextStyle poppinsTextField = poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Rosario
  static final TextStyle rosarioBold16 = rosario(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle rosarioRegular14 = rosario(fontSize: 14);
  static final TextStyle rosarioRegular16 = rosario(fontSize: 16);
  static final TextStyle rosarioRegular18 = rosario(fontSize: 18);
  static final TextStyle rosarioRegular20 = rosario(fontSize: 20);
  static final TextStyle rosarioTitle22 = rosario(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle rosarioButtonWhite16 = rosario(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ==== Aliases for Backward Compatibility ====

  // Poppins Aliases
  static final TextStyle poppinsBoldTextStyle = poppinsBold16;
  static final TextStyle poppinsBoldTextStyle16 = poppinsBold16;
  static final TextStyle poppinsNormalTextStyle = poppinsRegular14;
  static final TextStyle poppinsNormalTextStyle16 = poppinsRegular16;
  static final TextStyle poppinsNormalTextStyle18 = poppinsRegular18;
  static final TextStyle poppinsNormalTextStyle20 = poppinsRegular20;
  static final TextStyle poppinsTitleTextStyle = poppinsTitle22;
  static final TextStyle poppinsButtonTextStyle = poppinsButtonWhite16;
  static final TextStyle appHintTextFieldStyle = poppinsHint16;
  static final TextStyle appTextFieldStyle = poppinsTextField;

  // Rosario Aliases
  static final TextStyle rosarioBoldTextStyle = rosarioBold16;
  static final TextStyle rosarioNormalTextStyle = rosarioRegular14;
  static final TextStyle rosarioNormalTextStyle16 = rosarioRegular16;
  static final TextStyle rosarioNormalTextStyle18 = rosarioRegular18;
  static final TextStyle rosarioNormalTextStyle20 = rosarioRegular20;
  static final TextStyle rosarioTitleTextStyle = rosarioTitle22;
  static final TextStyle rosarioButtonTextStyle = rosarioButtonWhite16;
}
