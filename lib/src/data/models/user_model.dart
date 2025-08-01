import 'package:json_annotation/json_annotation.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/order.dart'
    show OrderModel;
import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  String? userID;
  String? name;
  String? email;
  String? phone;
  DateTime? dateOfBirth;
  String? profilePicture;
  DateTime? createdAt;
  List<CartItemModel>? cart;
  List<AddressModel>? addresses;
  List<OrderModel>? orders;
  List<String>? wishlist;

  UserModel({
    this.dateOfBirth,
    this.userID,
    this.name,
    this.email,
    this.phone,
    this.profilePicture,
    this.createdAt,
    this.cart,
    this.addresses,
    this.orders,
    this.wishlist,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? userID,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? profilePicture,
    DateTime? createdAt,
    List<CartItemModel>? cart,
    List<AddressModel>? addresses,
    List<OrderModel>? orders,
    List<String>? wishlist,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      cart: cart ?? this.cart,
      addresses: addresses ?? this.addresses,
      orders: orders ?? this.orders,
      wishlist: wishlist ?? this.wishlist,
    );
  }
}


@JsonSerializable(explicitToJson: true)
class CartItemModel {
  final Product? product;
  final int? quantity;
  final String? selectedColor;

  const CartItemModel({this.product, this.quantity, this.selectedColor});

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
}

@JsonSerializable()
class AddressModel {
  final String? label;
  final String? phoneNumber;
  final String? addressID;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final bool? isPrimary;

  const AddressModel({
    this.label,
    this.phoneNumber,
    this.addressID,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.isPrimary,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
