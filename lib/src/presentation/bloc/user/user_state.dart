import '../../../data/models/user_model.dart';

abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserLoadedState extends UserState {
  final UserModel user;

  UserLoadedState(this.user);
}

///add user state
class UserAddedState extends UserState {
  final UserModel user;

  UserAddedState(this.user);
}

class UserErrorState extends UserState {
  final String error;

  UserErrorState(this.error);
}
