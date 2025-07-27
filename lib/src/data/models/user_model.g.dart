// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  dateOfBirth:
      json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
  userID: json['userID'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  profilePicture: json['profilePicture'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  cart:
      (json['cart'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  addresses:
      (json['addresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  orders:
      (json['orders'] as List<dynamic>?)
          ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  wishlist:
      (json['wishlist'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'userID': instance.userID,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'profilePicture': instance.profilePicture,
  'createdAt': instance.createdAt?.toIso8601String(),
  'cart': instance.cart?.map((e) => e.toJson()).toList(),
  'addresses': instance.addresses?.map((e) => e.toJson()).toList(),
  'orders': instance.orders?.map((e) => e.toJson()).toList(),
  'wishlist': instance.wishlist,
};

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      product:
          json['product'] == null
              ? null
              : Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt(),
      selectedColor: json['selectedColor'] as String?,
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      'product': instance.product?.toJson(),
      'quantity': instance.quantity,
      'selectedColor': instance.selectedColor,
    };

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  label: json['label'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  addressID: json['addressID'] as String?,
  street: json['street'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  postalCode: json['postalCode'] as String?,
  isPrimary: json['isPrimary'] as bool?,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'phoneNumber': instance.phoneNumber,
      'addressID': instance.addressID,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'isPrimary': instance.isPrimary,
    };
