import 'package:dartz/dartz.dart';

abstract class AuthenticationRepository {
  Future<Either<String, void>> verifyPhoneNumber(String phoneNumber);
  Future<Either<String, void>> verifyOTPCode(String smsCode);
  Future<void> signOut();
}