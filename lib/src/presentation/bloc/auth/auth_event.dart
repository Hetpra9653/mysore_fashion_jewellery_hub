abstract class AuthenticationEvent {}

class VerifyPhoneNumberEvent extends AuthenticationEvent {
  final String phoneNumber;
  final bool isFromLogin;

  VerifyPhoneNumberEvent({required this.phoneNumber,required this.isFromLogin});
}

class VerifyOTPCodeEvent extends AuthenticationEvent {
  final String smsCode;
  final String phoneNumber;
  final bool isFromLogin;

  VerifyOTPCodeEvent({
    required this.smsCode,
    required this.phoneNumber,
    required this.isFromLogin,
  });
}
