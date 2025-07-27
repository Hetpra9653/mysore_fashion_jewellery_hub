import 'package:dartz/dartz.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/user/user_repository.dart';

class FetchUserByPhoneNumberUseCase {
  final UserRepository _userRepository;

  FetchUserByPhoneNumberUseCase(this._userRepository);

  Future<Either<String, UserModel>> call(String phoneNumber) async {
    return await _userRepository.fetchUserByPhoneNumber(phoneNumber);
  }
}