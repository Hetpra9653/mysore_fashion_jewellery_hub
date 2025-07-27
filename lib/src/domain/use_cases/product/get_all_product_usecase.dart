import 'package:dartz/dartz.dart';
import '../../../data/models/product.dart';
import '../../repositories/product/product_repository.dart';

class GetAllProductsUseCase {
  final ProductRepository repository;
  GetAllProductsUseCase(this.repository);

  Future<Either<String, List<Product>>> call() => repository.getAllProducts();
}
