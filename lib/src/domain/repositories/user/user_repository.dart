import 'package:dartz/dartz.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<String, UserModel>> fetchUser(String userId);

  ///fetch user by phone number
  Future<Either<String, UserModel>> fetchUserByPhoneNumber(String phoneNumber);

  ///add user
  Future<Either<String, UserModel>> addUser(UserModel userModel);
}
