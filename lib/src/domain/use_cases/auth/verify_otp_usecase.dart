
import 'package:dartz/dartz.dart';

import '../../repositories/auth/authentication_repository.dart';

class VerifyOTPUseCase {
  final AuthenticationRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<Either<String,void>> call(String smsCode) {
    return repository.verifyOTPCode(smsCode);
  }
}
