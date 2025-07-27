import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

abstract class UserEvent {}

class FetchUserEvent extends UserEvent {
  final String userId;

  FetchUserEvent({required this.userId});
}

class AddUserEvent extends UserEvent {
  final UserModel userModel;

  AddUserEvent({required this.userModel});
}
