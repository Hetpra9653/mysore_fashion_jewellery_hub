import 'package:dartz/dartz.dart';
import '../../../data/models/category.dart';
import '../../repositories/category/category_repository.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository repository;
  GetAllCategoriesUseCase(this.repository);

  Future<Either<String, List<Category>>> call() {
    return repository.getAllCategories();
  }
}

class GetCategoryByIdUseCase {
  final CategoryRepository repository;
  GetCategoryByIdUseCase(this.repository);

  Future<Either<String, Category>> call(String id) {;
    return repository.getCategoryById(id);
  }
}


