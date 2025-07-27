
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

import '../../../data/models/product.dart';

abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final Product product;
  final int quantity;
  final String? selectedColor;

  AddToCartEvent({
    this.selectedColor,
    required this.product,
    this.quantity = 1,
  });
}

class IncreaseQuantityEvent extends CartEvent {
  final Product product;

  IncreaseQuantityEvent({
    required this.product,
  });
}

class DecreaseQuantityEvent extends CartEvent {
  final Product product;

  DecreaseQuantityEvent({
    required this.product,
  });
}

class RemoveFromCartEvent extends CartEvent {
  final Product product;

  RemoveFromCartEvent({
    required this.product,
  });
}

class UpdateCartEvent extends CartEvent {
  final List<CartItemModel> cartItems;

  UpdateCartEvent({
    required this.cartItems,
  });
}

class ClearCartEvent extends CartEvent {}