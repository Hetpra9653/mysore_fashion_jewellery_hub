import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoadingState extends AuthenticationState {}

class PhoneNumberVerifiedState extends AuthenticationState {
  final String phoneNumber;


  PhoneNumberVerifiedState({required this.phoneNumber});
}

///user not exists state
class UserNotExistsState extends AuthenticationState {
  final String phoneNumber;

  UserNotExistsState({required this.phoneNumber});
}

class PhoneAuthenticationSuccessState extends AuthenticationState {
  final String phoneNumber;
  final bool isFromLogin;
  final UserModel? userModel;
  PhoneAuthenticationSuccessState( {
    this.userModel,
    required this.phoneNumber,
    required this.isFromLogin,
  });
}

class PhoneAuthenticationFailureState extends AuthenticationState {
  final String error;

  PhoneAuthenticationFailureState(this.error);
}
