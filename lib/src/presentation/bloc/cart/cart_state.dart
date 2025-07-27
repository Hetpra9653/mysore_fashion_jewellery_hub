import '../../../data/models/user_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> cartItems;
  final double subTotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  CartLoaded({
    required this.cartItems,
    required this.subTotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });
}

class CartUnauthenticated extends CartState {}

class CartFailure extends CartState {
  final String message;

  CartFailure({required this.message});
}
