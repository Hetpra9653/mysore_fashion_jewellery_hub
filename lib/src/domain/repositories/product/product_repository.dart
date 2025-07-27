import 'package:dartz/dartz.dart';
import '../../../data/models/product.dart';

abstract class ProductRepository {
  Future<Either<String, List<Product>>> getAllProducts();
  Future<Either<String, Product>> getProductById(String id);
  Future<Either<String, Product>> addReview(Review review, String productId);
}
