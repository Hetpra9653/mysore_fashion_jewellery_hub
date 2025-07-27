import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:mysore_fashion_jewellery_hub/generated/l10n.dart';
import '../../../core/utils/response.dart';
import '../../models/product.dart';
import '../../../domain/repositories/product/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepositoryImpl({required this.firestore});

  @override
  Future<Either<String, List<Product>>> getAllProducts() async {
    try {
      final snapshot = await firestore.collection('products').get();
      final products =
      snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
      return Right(products);
    } catch (e) {
      return Left("Failed to fetch products: $e");
    }
  }

  @override
  Future<Either<String, Product>> getProductById(String id) async {
    try {
      final doc = await firestore.collection('products').doc(id).get();
      if (!doc.exists) return Left("Product not found");
      return Right(Product.fromJson(doc.data()!));
    } catch (e) {
      return Left("Failed to fetch product by ID: $e");
    }
  }

  @override
  Future<Either<String, Product>> addReview(
      Review review,
      String productId,
      ) async {
    try {
      final doc = await firestore.collection('products').doc(productId).get();
      if (!doc.exists) return Left("Product not found");

      final product = Product.fromJson(doc.data()!);

      // Handle null reviews list by creating a new list
      List<Review> updatedReviews = List<Review>.from(product.reviews ?? []);
      updatedReviews.add(review);

      final updatedProduct = product.copyWith(
        reviews: updatedReviews,
        updatedAt: DateTime.now(),
      );

      Map<String, dynamic> productJson = updatedProduct.toJson();

      productJson['reviews'] = updatedReviews.map((r) => r.toJson()).toList();

      await firestore
          .collection('products')
          .doc(productId)
          .update(productJson);

      return Right(updatedProduct);
    } catch (e) {
      return Left("Failed to add review: $e");
    }
  }
}
