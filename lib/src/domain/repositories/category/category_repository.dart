import 'package:dartz/dartz.dart';
import '../../../data/models/category.dart';

abstract class CategoryRepository {
  Future<Either<String, List<Category>>> getAllCategories();
  Future<Either<String, Category>> getCategoryById(String id);
}
