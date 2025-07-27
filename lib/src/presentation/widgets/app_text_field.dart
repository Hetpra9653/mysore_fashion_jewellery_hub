import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 4.0,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.showCounter = false,
    this.showBorder = false,
    this.isDense = false,
  });

  // Required properties
  final TextEditingController controller;
  final String hintText;

  // Optional text properties
  final String? labelText;
  final String? prefixText;
  final String? suffixText;

  // Optional icon properties
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  // Input behavior properties
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;

  // Callback functions
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  // Styling properties
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final bool showCounter;
  final bool showBorder;
  final bool isDense;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final FocusNode defaultFocusNode = FocusNode();
    final FocusNode focusNode = this.focusNode ?? defaultFocusNode;
    return TextFormField(
      onTapOutside: (event) {
        focusNode.unfocus();
      },
      textAlignVertical: TextAlignVertical.center,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: textStyle ?? AppTextStyle.appTextFieldStyle,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle: hintStyle ?? AppTextStyle.appHintTextFieldStyle,
        labelStyle:
            labelStyle ??
            TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
        errorStyle: errorStyle ?? TextStyle(color: Colors.red, fontSize: 12.sp),
        filled: true,
        fillColor: AppColors.whiteColor,
        isDense: isDense,
        counterText: showCounter ? null : '',
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(vertical: 15.h, horizontal: 12.w),
        border:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(
                    color: borderColor ?? Colors.grey.shade400,
                  ),
                )
                : InputBorder.none,
        enabledBorder:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(
                    color: borderColor ?? Colors.grey.shade400,
                  ),
                )
                : InputBorder.none,
        focusedBorder:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(
                    color: borderColor ?? Theme.of(context).primaryColor,
                    width: 1.5.w,
                  ),
                )
                : InputBorder.none,
        errorBorder:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.w),
                )
                : InputBorder.none,
        focusedErrorBorder:
            showBorder
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5.w),
                )
                : InputBorder.none,
      ),
    );
  }
}
