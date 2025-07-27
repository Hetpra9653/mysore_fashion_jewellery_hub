import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      indicatorType: Indicator.ballBeat,
      colors: [
        AppColors.logoBlueColor.withValues(alpha: 0.3),
        AppColors.logoBlueColor.withValues(alpha: 0.6),
        AppColors.logoBlueColor,
      ],
    );
  }
}
