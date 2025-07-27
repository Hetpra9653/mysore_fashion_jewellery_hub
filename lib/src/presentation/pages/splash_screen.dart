import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_images.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the next screen
      if (mounted) {
        context.go(AppRoutes.landingPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG Image
          SvgPicture.asset(AppImages.splashBg),

          // Centered logo
          Center(
            child: Image.asset(
              AppImages
                  .logoWithoutText, // Make sure you have the logo in your assets
              width: 300.w,
              height: 300.h,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60.0.h),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Powered by ',
                      style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                        fontWeight: FontWeight.w200,
                        fontSize: 12.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' Ramdev Novelties',
                      style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                        color: AppColors.textBlueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
