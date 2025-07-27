import 'package:flutter/material.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/loading_to_dart.dart';
import '../../core/constants/app_colors.dart';
import 'app_button_loading_indicator.dart';

class ButtonAnimatedLoadingWidget extends StatelessWidget {
  final LoadingToDoneTransitionController controller;
  final double? height;
  final double? width;
  final Widget button;
  final bool border;
  final Widget? failedWidget;
  final Color? failedColor;
  final double? iconSize;

  const ButtonAnimatedLoadingWidget({
    super.key,
    this.border = true,
    required this.controller,
    this.height,
    this.width,
    required this.button,
    this.failedWidget,
    this.failedColor = Colors.red,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Align(
        alignment: Alignment.center,
        child: LoadingToDoneTransition(
          initial: button,
          loadingWidget: const SizedBox(
            width: 30,
            height: 30,
            child: AppLoadingIndicator(),
          ),
          finalWidget: Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.logoBlueColor,
            size: iconSize,
          ),
          // Use custom failed widget if provided, otherwise use default error icon
          failedWidget: failedWidget ?? Icon(
            Icons.error_outline_rounded,
            color: failedColor,
            size: iconSize,
          ),
          failedColor: failedColor,
          controller: controller,
        ),
      ),
    );
  }
}