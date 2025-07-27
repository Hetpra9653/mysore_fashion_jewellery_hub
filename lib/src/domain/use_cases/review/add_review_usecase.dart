import 'package:dartz/dartz.dart';
import '../../../data/models/product.dart';
import '../../repositories/product/product_repository.dart';

class AddReviewUseCase {
  final ProductRepository repository;
  AddReviewUseCase(this.repository);

  Future<Either<String, Product>> call(Review review, String productId) =>
      repository.addReview(review, productId);
}
