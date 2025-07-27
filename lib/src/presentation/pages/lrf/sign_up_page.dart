import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_constants.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_state.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_button.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/button_loading_animated_widget.dart';
import 'package:toastification/toastification.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/routes.dart';
import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_to_dart.dart';

class SignUpPage extends StatefulWidget {
  final String phoneNumber;
  const SignUpPage({super.key, required this.phoneNumber});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final UserSession userSession = sl<UserSession>();
  final AuthenticationBloc authenticationBloc = sl<AuthenticationBloc>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? dob;
  bool _isSubmitting = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoadingToDoneTransitionController loadingToDoneTransitionController =
      LoadingToDoneTransitionController();

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
      final UserModel userModel = UserModel(
        name: nameController.text,
        email: emailController.text,
        phone: '+91${phoneNumberController.text}',
        dateOfBirth: dob,
      );
      userSession.setUser(userModel);

      authenticationBloc.add(
        VerifyPhoneNumberEvent(
          phoneNumber: '+91${phoneNumberController.text}',
          isFromLogin: false,
        ),
      );
    }
  }

  // Validate full name (non-empty, no numbers or special characters)
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    // Check if name contains only alphabets and spaces
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Name should contain only alphabets';
    }

    // Check minimum length
    if (value.trim().length < 3) {
      return 'Name should be at least 3 characters';
    }

    return null;
  }

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Function to validate Indian phone number (exactly 10 digits)
  String? _validateIndianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (value.length != 10) {
      return 'Enter valid 10-digit mobile number';
    }

    // Check if the phone number contains only digits
    final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number should contain only digits';
    }

    // Check if phone number starts with valid Indian mobile prefixes
    if (!value.startsWith(RegExp(r'[6-9]'))) {
      return 'Indian mobile numbers should start with 6, 7, 8, or 9';
    }

    return null;
  }

  // Validate date of birth
  String? _validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }

    if (dob == null) {
      return 'Please select a valid date';
    }

    // Check if the user is at least 13 years old
    final DateTime today = DateTime.now();
    final DateTime minimumAgeDate = DateTime(
      today.year - 13,
      today.month,
      today.day,
    );

    if (dob!.isAfter(minimumAgeDate)) {
      return 'You must be at least 13 years old';
    }

    // Check if date is not in the future
    if (dob!.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }

    return null;
  }

  @override
  void initState() {
    loadingToDoneTransitionController.initial();
    // Initialize the phone number controller with the provided phone number if start with +91 remove it
    if (widget.phoneNumber.startsWith('+91')) {
      phoneNumberController.text = widget.phoneNumber.substring(3);
    } else {
      phoneNumberController.text = widget.phoneNumber;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      bloc: authenticationBloc,
      listener: (context, state) {
        if (state is AuthenticationLoadingState) {
          loadingToDoneTransitionController.loading();
        } else if (state is PhoneNumberVerifiedState) {
          loadingToDoneTransitionController.done();
          // Navigate to OTP page after animation completes
          Future.delayed( Duration(milliseconds: 600), () {
            context
                .push(
                  AppRoutes.otp,
                  extra: {AppConstants.phoneNumber : '+91 ${phoneNumberController.text}'},
                )
                .then((value) {
                  _resetButtonState();
                });
          });
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
      child: Scaffold(
        appBar: AppBar(
          shadowColor: AppColors.black333333Color.withValues(alpha: 0.1),
          elevation: 0.5.sp,
          scrolledUnderElevation: 0.sp,
          backgroundColor: AppColors.scaffoldBackground,
          title: InkWell(
            onTap: () {
              if (kDebugMode) {
                nameController.text = 'Prajapati Het Harshadkumar';
                emailController.text = 'prajapatihet2611@mailinator.com';
                dateController.text = '26/11/2002';
              }
            },
            child: Text(
              'Sign Up',
              style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black333333Color,
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.scaffoldBackground,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                TextFieldLabelWidget(label: 'Full Name'),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: nameController,
                  hintText: 'Enter your name',
                  validator: _validateFullName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                TextFieldLabelWidget(label: 'Email'),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: emailController,
                  hintText: 'Enter your email',
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                TextFieldLabelWidget(label: 'Phone Number'),
                SizedBox(height: 10.h),
                AppTextField(
                  prefixIcon: Container(
                    margin: EdgeInsets.only(right: 5.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      '+91',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                    ),
                  ),
                  controller: phoneNumberController,
                  hintText: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: _validateIndianPhoneNumber,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                TextFieldLabelWidget(label: 'Date of Birth'),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: dateController,
                  validator: _validateDateOfBirth,
                  readOnly: true,
                  onTap: () async {
                    final DateTime currentDate = DateTime.now();
                    final DateTime minDate = DateTime(1900);
                    final DateTime maxDate = currentDate;

                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          dob ??
                          DateTime(
                            currentDate.year - 18,
                            currentDate.month,
                            currentDate.day,
                          ),
                      firstDate: minDate,
                      lastDate: maxDate,
                      currentDate: currentDate,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            primaryColor: AppColors.logoBlueColor,
                            datePickerTheme: DatePickerThemeData(
                              elevation: 0,
                              backgroundColor: AppColors.scaffoldBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(0.r),
                                ),
                              ),
                            ),
                          ),
                          child: child ?? SizedBox.shrink(),
                        );
                      },
                    );

                    if (selectedDate != null) {
                      setState(() {
                        dob = selectedDate;
                        // Format the date as DD/MM/YYYY
                        dateController.text =
                            "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";
                      });
                    }
                  },
                  hintText: 'Enter your date of birth',
                  prefixIcon: Container(
                    margin: EdgeInsets.only(right: 5.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Icon(Icons.calendar_today_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 30.h),
                ButtonAnimatedLoadingWidget(
                  height: 50.h,
                  controller: loadingToDoneTransitionController,
                  border: true,
                  button: AppButton(
                    buttonText: 'CONTINUE',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dateController.dispose();
    super.dispose();
  }
}

class TextFieldLabelWidget extends StatelessWidget {
  final String label;
  const TextFieldLabelWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.poppinsTitleTextStyle.copyWith(
        fontSize: 13.sp,
        height: 26.9 / 13,
        color: AppColors.black333333Color,
      ),
    );
  }
}
