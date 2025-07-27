// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  orderID: json['orderID'] as String?,
  userID: json['userID'] as String?,
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => OrderProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  status: json['status'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  shippingAddress:
      json['shippingAddress'] == null
          ? null
          : ShippingAddress.fromJson(
            json['shippingAddress'] as Map<String, dynamic>,
          ),
  orderedAt:
      json['orderedAt'] == null
          ? null
          : DateTime.parse(json['orderedAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  shippingDetails:
      json['shippingDetails'] == null
          ? null
          : ShippingDetails.fromJson(
            json['shippingDetails'] as Map<String, dynamic>,
          ),
  paymentDetails:
      json['paymentDetails'] == null
          ? null
          : PaymentDetails.fromJson(
            json['paymentDetails'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderID': instance.orderID,
      'userID': instance.userID,
      'products': instance.products,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'shippingAddress': instance.shippingAddress,
      'orderedAt': instance.orderedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'shippingDetails': instance.shippingDetails,
      'paymentDetails': instance.paymentDetails,
    };

OrderProduct _$OrderProductFromJson(Map<String, dynamic> json) => OrderProduct(
  color: json['color'] as String?,
  productID: json['productID'] as String?,
  quantity: (json['quantity'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderProductToJson(OrderProduct instance) =>
    <String, dynamic>{
      'productID': instance.productID,
      'quantity': instance.quantity,
      'price': instance.price,
      'color': instance.color,
    };

ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    ShippingAddress(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$ShippingAddressToJson(ShippingAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
    };

ShippingDetails _$ShippingDetailsFromJson(Map<String, dynamic> json) =>
    ShippingDetails(
      trackingNumber: json['trackingNumber'] as String?,
      courierService: json['courierService'] as String?,
    );

Map<String, dynamic> _$ShippingDetailsToJson(ShippingDetails instance) =>
    <String, dynamic>{
      'trackingNumber': instance.trackingNumber,
      'courierService': instance.courierService,
    };

PaymentDetails _$PaymentDetailsFromJson(Map<String, dynamic> json) =>
    PaymentDetails(
      transactionID: json['transactionID'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );

Map<String, dynamic> _$PaymentDetailsToJson(PaymentDetails instance) =>
    <String, dynamic>{
      'transactionID': instance.transactionID,
      'paymentMethod': instance.paymentMethod,
    };
