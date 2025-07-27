import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class OrderModel {
  final String? orderID;
  final String? userID;
  final List<OrderProduct>? products;
  final double? totalAmount;
  final String? status;
  final String? paymentStatus;
  final ShippingAddress? shippingAddress;
  final DateTime? orderedAt;
  final DateTime? updatedAt;
  final ShippingDetails? shippingDetails;
  final PaymentDetails? paymentDetails;

  OrderModel({
    this.orderID,
    this.userID,
    this.products,
    this.totalAmount,
    this.status,
    this.paymentStatus,
    this.shippingAddress,
    this.orderedAt,
    this.updatedAt,
    this.shippingDetails,
    this.paymentDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderProduct {
  final String? productID;
  final int? quantity;
  final double? price;
  final String? color;

  OrderProduct({
    this.color,
    this.productID,
    this.quantity,
    this.price,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) => _$OrderProductFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductToJson(this);
}

@JsonSerializable()
class ShippingAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;

  ShippingAddress({
    this.street,
    this.city,
    this.state,
    this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingAddressToJson(this);
}

@JsonSerializable()
class ShippingDetails {
  final String? trackingNumber;
  final String? courierService;

  ShippingDetails({
    this.trackingNumber,
    this.courierService,
  });

  factory ShippingDetails.fromJson(Map<String, dynamic> json) => _$ShippingDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingDetailsToJson(this);
}

@JsonSerializable()
class PaymentDetails {
  final String? transactionID;
  final String? paymentMethod;

  PaymentDetails({
    this.transactionID,
    this.paymentMethod,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => _$PaymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDetailsToJson(this);
}
