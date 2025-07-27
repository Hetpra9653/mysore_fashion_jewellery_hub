import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, this.onPressed, required this.buttonText});

  final VoidCallback? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.buttonBlueColor,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBlueColor,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.r),
          ),
        ),
        child: Text(buttonText, style: AppTextStyle.rosarioButtonTextStyle),
      ),
    );
  }
}
