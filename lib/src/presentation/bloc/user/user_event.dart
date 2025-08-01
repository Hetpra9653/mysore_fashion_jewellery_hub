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

class AddAddressEvent extends UserEvent {
  final AddressModel newAddress;
  final bool makeDefault;

  AddAddressEvent({required this.newAddress, required this.makeDefault});
}

class EditAddressEvent extends UserEvent {
  final AddressModel updatedAddress;
  final bool makeDefault;

  EditAddressEvent({required this.updatedAddress, required this.makeDefault});
}

class DeleteAddressEvent extends UserEvent {
  final String addressId;

  DeleteAddressEvent({required this.addressId});
}
class FetchAddressesEvent extends UserEvent {
  final String userId;

  FetchAddressesEvent({required this.userId});
}

