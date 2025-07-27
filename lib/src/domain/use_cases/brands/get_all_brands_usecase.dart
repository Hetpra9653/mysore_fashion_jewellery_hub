import 'package:dartz/dartz.dart';

import '../../../data/models/brands.dart';
import '../../repositories/exclusive brand/exclusive_brand.dart';

class GetAllBrandsUseCase {
  final ExclusiveBrandRepository repository;
  GetAllBrandsUseCase(this.repository);

  Future<Either<String, List<Brands>>> call() {
    return repository.getAllBrands();
  }
}

class GetBrandsByIdUseCase {
  final ExclusiveBrandRepository repository;

  GetBrandsByIdUseCase(this.repository);

  Future<Either<String, Brands>> call(String id) {
    return repository.getBrandsById(id);
  }

}

