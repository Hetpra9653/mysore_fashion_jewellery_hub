import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/fetch_user_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_state.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_state.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../../data/entity/user_session.dart';
import '../../widgets/app_button.dart';
import '../../widgets/button_loading_animated_widget.dart';
import '../../widgets/loading_to_dart.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final bool isFromLogin;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.isFromLogin,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final AuthenticationBloc authenticationBloc = sl<AuthenticationBloc>();
  final UserBloc userBloc = sl<UserBloc>();
  final FetchUserUseCase fetchUserUseCase = sl<FetchUserUseCase>();
  final TextEditingController otpController = TextEditingController();
  final LoadingToDoneTransitionController loadingToDoneTransitionController =
      LoadingToDoneTransitionController();

  bool isProcessing = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  void _handleOtpVerification() {
    if (otpController.text.isEmpty || otpController.text.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a valid OTP')));
      return;
    }

    setState(() {
      isProcessing = true;
    });

    authenticationBloc.add(
      VerifyOTPCodeEvent(
        smsCode: otpController.text,
        phoneNumber: widget.phoneNumber,
        isFromLogin: widget.isFromLogin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          bloc: authenticationBloc,
          listener: (context, state) {
            if (state is AuthenticationLoadingState) {
              loadingToDoneTransitionController.loading();
            } else if (state is PhoneAuthenticationSuccessState) {
              if (state.isFromLogin) {
                userBloc.add(
                  FetchUserEvent(userId: firebaseAuth.currentUser?.uid ?? ''),
                );
              } else {
                if (state.userModel != null) {
                  loadingToDoneTransitionController.animateToDone();

                  userBloc.add(AddUserEvent(userModel: state.userModel!));
                  debugPrint('User model: ${state.userModel}');
                }
              }
            } else if (state is PhoneAuthenticationFailureState) {
              loadingToDoneTransitionController.animateToFailed();
              Future.delayed(const Duration(milliseconds: 600), () {
                loadingToDoneTransitionController.initial();
                isProcessing = false;
              });
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          bloc: userBloc,
          listener: (context, state) {
            if (state is UserLoadingState) {
              loadingToDoneTransitionController.loading();
            } else if (state is UserLoadedState) {
              sl<UserSession>().setUser(state.user);
              loadingToDoneTransitionController.animateToDone();
              debugPrint('User loaded: ${state.user}');
              context.pop();

            } else if (state is UserAddedState) {
              userBloc.add(FetchUserEvent(userId: firebaseAuth.currentUser?.uid ?? ''));
            } else if (state is UserErrorState) {
              loadingToDoneTransitionController.animateToFailed();
              Future.delayed(const Duration(milliseconds: 600), () {
                loadingToDoneTransitionController.initial();
                isProcessing = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User error: ${state.error}')),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w),
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'MFJH',
            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
              fontSize: 28.sp,
              color: AppColors.logoBlueColor,
            ),
          ),
          leadingWidth: 40.w,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'OTP verification',
                style: AppTextStyle.poppinsTitleTextStyle,
              ),
              SizedBox(height: 28.h),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Please enter the verification code we\'ve sent',
                    textAlign: TextAlign.start,
                    style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                      fontSize: 16.sp,
                      color: const Color(0xff606060),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'you on ${widget.phoneNumber}',
                        textAlign: TextAlign.start,
                        style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                          fontSize: 16.sp,
                          color: const Color(0xff606060),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (!isProcessing) {
                            context.pop();
                          }
                        },
                        child: Text(
                          ' Edit',
                          textAlign: TextAlign.start,
                          style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textBlueColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              AppTextField(
                controller: otpController,
                hintText: 'Enter OTP',
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              SizedBox(height: 14.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10.w),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (!isProcessing) {
                        // Resend OTP functionality
                        authenticationBloc.add(
                          VerifyPhoneNumberEvent(
                            phoneNumber: widget.phoneNumber,
                            isFromLogin: widget.isFromLogin,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP sent again')),
                        );
                      }
                    },
                    child: Text(
                      'Resend OTP',
                      textAlign: TextAlign.start,
                      style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.textBlueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),

              ///AppButton
              ButtonAnimatedLoadingWidget(
                height: 50.h,
                controller: loadingToDoneTransitionController,
                border: true,
                button: AppButton(
                  buttonText: 'VERIFY',
                  onPressed: isProcessing ? null : _handleOtpVerification,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
