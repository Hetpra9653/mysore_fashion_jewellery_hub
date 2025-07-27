import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_constants.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_state.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/lrf/otp_page.dart';
import 'package:toastification/toastification.dart';

import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/button_loading_animated_widget.dart';
import '../../widgets/loading_to_dart.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  _LoginBottomSheetState createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final LoadingToDoneTransitionController loadingToDoneTransitionController = LoadingToDoneTransitionController();

  final AuthenticationBloc _authBloc = sl<AuthenticationBloc>();
  bool _isSubmitting = false;

  @override
  void initState() {
    loadingToDoneTransitionController.initial();
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _resetButtonState() {
    setState(() {
      _isSubmitting = false;
    });
    loadingToDoneTransitionController.initial();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });
      loadingToDoneTransitionController.loading();

      // Use the bloc from context
      _authBloc.add(VerifyPhoneNumberEvent(phoneNumber: '+91${_phoneController.text}', isFromLogin: true));
    }
  }

  // Function to validate Indian phone number (exactly 10 digits)
  String? _validateIndianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Enter valid 10-digit mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthenticationLoadingState) {
          // Already handled when button is pressed
        } else if (state is PhoneNumberVerifiedState) {
          loadingToDoneTransitionController.done();
          // Navigate to OTP page after animation completes
          Future.delayed(Duration(milliseconds: 600), () {
            context
                .push(
                  AppRoutes.otp,
                  extra: {AppConstants.phoneNumber: _phoneController.text, AppConstants.isFromLogin: true},
                )
                .then((value) {
                  _resetButtonState();
                });
          });
        } else if (state is UserNotExistsState) {
          loadingToDoneTransitionController.initial();
          // Navigate to SignUp page after animation completes
          if (context.mounted) {
            Future.delayed(const Duration(milliseconds: 600), () {
              context.push(AppRoutes.signUp, extra: {AppConstants.phoneNumber: _phoneController.text}).then((value) {
                _resetButtonState();
              });
            });
          }
        } else if (state is PhoneAuthenticationFailureState) {
          // Handle failure - reset button state and show error
          _resetButtonState();

          // Show toast notification with error message
          toastification.show(
            style: ToastificationStyle.minimal,
            context: context,
            title: Text(state.error),
            autoCloseDuration: const Duration(seconds: 5),
            type: ToastificationType.error,
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDF8F1), // Cream background color
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with logo and close button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.upperLogoBgColor,
                    border: Border(bottom: BorderSide(width: 1.w, color: Colors.grey.shade300)),
                  ),
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Jewellery text logo
                      InkWell(
                        onTap: () {
                          if (kDebugMode) {
                            _phoneController.text = '9426920533';
                          }
                        },
                        child: Text(
                          'Mysore Fashion\nJewellery Hub',
                          style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                            color: AppColors.logoBlueColor,
                            fontSize: 24.sp,
                          ),
                        ),
                      ),
                      // Close button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Icon(Icons.close, color: Colors.grey.shade700, size: 30.r),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Login',
                            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black333333Color,
                            ),
                          ),
                          Text(
                            ' or ',
                            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                              fontSize: 16.sp,
                              color: AppColors.black333333Color,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                          Text(
                            'Signup',
                            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black333333Color,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 25.h),

                      // Phone input field
                      AppTextField(
                        prefixIcon: Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
                          decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
                          child: Text(
                            '+91',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                          ),
                        ),
                        controller: _phoneController,
                        hintText: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: _validateIndianPhoneNumber,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),

                      SizedBox(height: 20.h),

                      // Terms & Conditions
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                          children: [
                            const TextSpan(text: 'By Continuing, I agree to the '),
                            TextSpan(
                              text: 'Terms of Use',
                              style: TextStyle(color: Colors.blue, fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Colors.blue, fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25.h),

                      // Continue Button with loading animation
                      ButtonAnimatedLoadingWidget(
                        height: 50.h,
                        controller: loadingToDoneTransitionController,
                        border: true,
                        button: AppButton(buttonText: 'CONTINUE', onPressed: _isSubmitting ? null : _handleSubmit),
                      ),

                      SizedBox(height: 20.h),

                      // Help text
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            children: [
                              const TextSpan(text: 'Having trouble logging in? '),
                              TextSpan(
                                text: 'Get help',
                                style: TextStyle(color: Colors.blue, fontSize: 14.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
