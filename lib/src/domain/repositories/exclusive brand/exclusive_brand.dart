import 'package:dartz/dartz.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/brands.dart';

abstract class ExclusiveBrandRepository {
  Future<Either<String, List<Brands>>> getAllBrands();
  Future<Either<String, Brands>> getBrandsById(String id);
}
