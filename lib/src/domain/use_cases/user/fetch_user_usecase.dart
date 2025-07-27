import 'package:mysore_fashion_jewellery_hub/src/core/utils/response.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/user/user_repository.dart';

import 'package:dartz/dartz.dart';

class FetchUserUseCase {
  final UserRepository userRepository;

  FetchUserUseCase(this.userRepository);

  Future<Either<String, UserModel>> call(String userId) {
    return userRepository.fetchUser(userId);
  }
}

