import 'package:dartz/dartz.dart';

import '../../../data/models/user_model.dart';
import '../../repositories/user/user_repository.dart';

class AddUserUseCase{
  final UserRepository userRepository;

  AddUserUseCase(this.userRepository);

  Future<Either<String, UserModel>> call(UserModel userModel) async {
    return await userRepository.addUser(userModel);
  }
}