import 'package:dartz/dartz.dart';
import '../../../data/models/product.dart';
import '../../repositories/product/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository repository;
  GetProductByIdUseCase(this.repository);

  Future<Either<String, Product>> call(String id) => repository.getProductById(id);
}
