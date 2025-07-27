import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repositories/auth/authentication_repository.dart';

class VerifyPhoneUseCase {
  final AuthenticationRepository repository;

  VerifyPhoneUseCase(this.repository);

  Future<Either<String, void>> call(String phoneNumber) {
    return repository.verifyPhoneNumber(phoneNumber);
  }
}
