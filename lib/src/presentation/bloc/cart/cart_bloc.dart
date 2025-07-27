import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_state.dart';

import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../../data/models/product.dart';
import '../../../data/models/user_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserSession _userSession = sl<UserSession>();

  // Constants for shipping and tax calculations
  static const double _shippingFee = 5.99;
  static const double _taxRate = 0.10; // 10%
  static const double _freeShippingThreshold = 50.0;

  Map<String, Product> _productCache = {};

  CartBloc() : super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<IncreaseQuantityEvent>(_onIncreaseQuantity);
    on<DecreaseQuantityEvent>(_onDecreaseQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartEvent>(_onUpdateCart);
    on<ClearCartEvent>(_onClearCart);
  }

  /// Helper method to get authenticated user or emit unauthenticated state
  Future<String?> _getAuthenticatedUserId(Emitter<CartState> emit) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(CartUnauthenticated());
      return null;
    }
    return currentUser.uid;
  }

  /// Helper method to get and validate user data
  Future<UserModel?> _getUserData(
    String userId,
    Emitter<CartState> emit,
  ) async {
    // First check if we have valid user in session
    if (_userSession.user != null) {
      return _userSession.user;
    }

    // If not in session, fetch from Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        emit(CartFailure(message: 'User profile not found'));
        return null;
      }

      final userData = userDoc.data()!;
      return UserModel.fromJson(userData);
    } catch (e) {
      emit(CartFailure(message: 'Failed to retrieve user data: $e'));
      return null;
    }
  }

  Future<void> _saveUserCart(
    String userId,
    List<CartItemModel> updatedCart,
  ) async {
    try {
      // Convert cart items to JSON before updating Firestore
      final List<CartItemModel> cartJson = updatedCart.toList();

      // Update in Firestore
      await _firestore.collection('users').doc(userId).update({
        'cart':
            cartJson.map((item) {
              return {
                'product': item.product?.toJson(),
                'quantity': item.quantity,
              };
            }).toList(),
      });

      // Update user session if it exists
      if (_userSession.user != null) {
        // Create new user model with updated cart
        final updatedUser = UserModel(
          userID: _userSession.user!.userID,
          name: _userSession.user!.name,
          email: _userSession.user!.email,
          phone: _userSession.user!.phone,
          profilePicture: _userSession.user!.profilePicture,
          createdAt: _userSession.user!.createdAt,
          cart: updatedCart,
          addresses: _userSession.user!.addresses,
          orders: _userSession.user!.orders,
          wishlist: _userSession.user!.wishlist,
        );
        _userSession.user = updatedUser;
      }
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  // Helper method to safely parse price strings
  double _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 0.0;
    try {
      // Remove currency symbol if present
      final cleanStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleanStr);
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to calculate cart totals
  Map<String, double> _calculateCartTotals(List<CartItemModel> cartItems) {
    double subTotal = 0.0;

    // Calculate subtotal
    for (var item in cartItems) {
      // Use the discountPrice if available, otherwise use the regular price
      final priceStr =
          item.product?.discountPrice?.isNotEmpty == true
              ? item.product?.discountPrice
              : item.product?.price;

      final price = _parsePrice(priceStr);
      final quantity = item.quantity ?? 1;
      subTotal += price * quantity;
    }

    // Calculate shipping (free if above threshold)
    double shipping = subTotal >= _freeShippingThreshold ? 0.0 : _shippingFee;

    // Calculate tax
    double tax = subTotal * _taxRate;

    // Calculate total
    double total = subTotal + shipping + tax;
    if (total < 0) total = 0; // Ensure total is not negative

    return {
      'subTotal': subTotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
    };
  }

  // Helper method to update state with new cart data
  void _emitLoadedState(
    List<CartItemModel> cartItems,
    Emitter<CartState> emit,
  ) {
    final totals = _calculateCartTotals(cartItems);

    emit(
      CartLoaded(
        cartItems: cartItems,
        subTotal: totals['subTotal']!,
        shipping: totals['shipping']!,
        tax: totals['tax']!,
        total: totals['total']!,
        discount: 0.0,
      ),
    );
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    try {
      // Only emit loading state for initial cart load
      emit(CartLoading());

      // Check if user is authenticated
      final userId = await _getAuthenticatedUserId(emit);
      if (userId == null) return;

      // Get user data
      final user = await _getUserData(userId, emit);
      if (user == null) return;

      // Clear product cache
      _productCache = {};

      // Process cart items
      List<CartItemModel> cartItems = [];
      if (user.cart != null && user.cart!.isNotEmpty) {
        for (var cartItem in user.cart!) {
          if (cartItem.product?.productID != null) {
            // Use the product from the cart item directly
            if (cartItem.product != null) {
              final cartItemWithProduct = CartItemModel(
                product: cartItem.product,
                quantity: cartItem.quantity ?? 1,
                selectedColor: cartItem.selectedColor,
              );
              cartItems.add(cartItemWithProduct);

              // Add to cache for future use
              _productCache[cartItem.product!.productID ?? ''] =
                  cartItem.product!;
            }
          }
        }
      }

      _emitLoadedState(cartItems, emit);
    } catch (e) {
      emit(CartFailure(message: 'Failed to load cart: $e'));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      // For adding items, we want to show loading state
      // as it may take time to update the database
      emit(CartLoading());

      // Check if user is authenticated
      final userId = await _getAuthenticatedUserId(emit);
      if (userId == null) return;

      // Get user data
      final user = await _getUserData(userId, emit);
      if (user == null) return;

      final product = event.product;

      // Cache the product
      if (product.productID != null) {
        _productCache[product.productID!] = product;
      }

      final List<CartItemModel> updatedCart = List<CartItemModel>.from(
        user.cart ?? [],
      );

      // Check if product already exists in cart
      int existingIndex = updatedCart.indexWhere(
        (item) => item.product?.productID == product.productID,
      );

      if (existingIndex != -1) {
        // Update quantity if product already exists
        final CartItemModel existingItem = updatedCart[existingIndex];
        updatedCart[existingIndex] = CartItemModel(
          product: existingItem.product,
          quantity: (existingItem.quantity ?? 0) + event.quantity,
          selectedColor: event.selectedColor,
        );
      } else {
        // If product doesn't exist in cart, add it
        updatedCart.add(
          CartItemModel(
            product: product,
            quantity: event.quantity,
            selectedColor: event.selectedColor,
          ),
        );
      }

      // Save updated cart
      await _saveUserCart(userId, updatedCart);

      _emitLoadedState(updatedCart, emit);
    } catch (e) {
      emit(CartFailure(message: 'Failed to add product to cart: $e'));
      // Reload cart
      add(LoadCartEvent());
    }
  }

  Future<void> _onIncreaseQuantity(
    IncreaseQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;

        // No loading state for quantity changes
        // This makes the UI more responsive

        // Check if user is authenticated
        final userId = await _getAuthenticatedUserId(emit);
        if (userId == null) return;

        final String productId = event.product.productID ?? '';
        if (productId.isEmpty) {
          emit(CartFailure(message: 'Invalid product ID'));
          return;
        }

        // Create a deep copy of the current cart items
        final List<CartItemModel> updatedCart = List<CartItemModel>.from(
          currentState.cartItems,
        );

        // Find product in cart and increase quantity
        int productIndex = updatedCart.indexWhere(
          (item) => item.product?.productID == productId,
        );

        if (productIndex == -1) {
          emit(CartFailure(message: 'Product not found in cart'));
          return;
        }

        // Update the quantity - immediately update UI state
        final CartItemModel existingItem = updatedCart[productIndex];
        updatedCart[productIndex] = CartItemModel(
          product: existingItem.product,
          quantity: (existingItem.quantity ?? 0) + 1,
          selectedColor: existingItem.selectedColor,
        );

        // First update UI immediately
        _emitLoadedState(updatedCart, emit);

        // Then save to database in background
        await _saveUserCart(userId, updatedCart);
      }
    } catch (e) {
      emit(CartFailure(message: 'Failed to increase quantity: $e'));
      // Reload cart
      add(LoadCartEvent());
    }
  }

  Future<void> _onDecreaseQuantity(
    DecreaseQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;

        // No loading state for quantity changes
        // This makes the UI more responsive

        // Check if user is authenticated
        final userId = await _getAuthenticatedUserId(emit);
        if (userId == null) return;

        final String productId = event.product.productID ?? '';
        if (productId.isEmpty) {
          emit(CartFailure(message: 'Invalid product ID'));
          return;
        }

        // Create a deep copy of the current cart items
        final List<CartItemModel> updatedCart = List<CartItemModel>.from(
          currentState.cartItems,
        );

        // Find product in cart
        int productIndex = updatedCart.indexWhere(
          (item) => item.product?.productID == productId,
        );

        if (productIndex == -1) {
          emit(CartFailure(message: 'Product not found in cart'));
          return;
        }

        // Get existing item and calculate new quantity
        final CartItemModel existingItem = updatedCart[productIndex];
        final int newQuantity = (existingItem.quantity ?? 0) - 1;

        // Remove product if quantity becomes 0 or less, otherwise update quantity
        if (newQuantity <= 0) {
          updatedCart.removeAt(productIndex);
        } else {
          updatedCart[productIndex] = CartItemModel(
            product: existingItem.product,
            quantity: newQuantity,
            selectedColor: existingItem.selectedColor,
          );
        }

        // First update UI immediately
        _emitLoadedState(updatedCart, emit);

        // Then save to database in background
        await _saveUserCart(userId, updatedCart);
      }
    } catch (e) {
      emit(CartFailure(message: 'Failed to decrease quantity: $e'));
      // Reload cart
      add(LoadCartEvent());
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;

        // No loading state for remove operations
        // This gives more immediate feedback

        // Check if user is authenticated
        final userId = await _getAuthenticatedUserId(emit);
        if (userId == null) return;

        final String productId = event.product.productID ?? '';
        if (productId.isEmpty) {
          emit(CartFailure(message: 'Invalid product ID'));
          return;
        }

        // Create a deep copy of the current cart items
        final List<CartItemModel> updatedCart = List<CartItemModel>.from(
          currentState.cartItems,
        );

        // Check the initial length to verify removal
        final initialLength = updatedCart.length;

        // Remove product from cart
        updatedCart.removeWhere((item) => item.product?.productID == productId);

        // Verify if product was found and removed
        if (updatedCart.length == initialLength) {
          emit(CartFailure(message: 'Product not found in cart'));
          return;
        }

        // First update UI immediately
        _emitLoadedState(updatedCart, emit);

        // Then save to database in background
        await _saveUserCart(userId, updatedCart);
      }
    } catch (e) {
      emit(CartFailure(message: 'Failed to remove product from cart: $e'));
      add(LoadCartEvent());
    }
  }

  Future<void> _onUpdateCart(
    UpdateCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      // We need loading state for bulk update operations
      emit(CartLoading());

      // Check if user is authenticated
      final userId = await _getAuthenticatedUserId(emit);
      if (userId == null) return;

      // Save the new cart items
      await _saveUserCart(userId, event.cartItems);

      _emitLoadedState(event.cartItems, emit);
    } catch (e) {
      emit(CartFailure(message: 'Failed to update cart: $e'));
      // Reload cart
      add(LoadCartEvent());
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      // We should show loading state for clear operation
      emit(CartLoading());

      // Check if user is authenticated
      final userId = await _getAuthenticatedUserId(emit);
      if (userId == null) return;

      // Clear cart by setting it to an empty list
      await _saveUserCart(userId, []);

      // Update state with empty cart
      emit(
        CartLoaded(
          cartItems: [],
          subTotal: 0.0,
          shipping: 0.0,
          tax: 0.0,
          total: 0.0,
          discount: 0.0,
        ),
      );
    } catch (e) {
      emit(CartFailure(message: 'Failed to clear cart: $e'));
      // Reload cart
      add(LoadCartEvent());
    }
  }
}
