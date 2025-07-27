import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../models/category.dart';
import '../../../domain/repositories/category/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore firestore;

  CategoryRepositoryImpl({required this.firestore});

  @override
  Future<Either<String, List<Category>>> getAllCategories() async {
    try {
      final snapshot = await firestore.collection('category').get();
      final categories = snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
      return Right(categories);
    } catch (e) {
      return Left('Failed to fetch categories: $e');
    }
  }

  @override
  Future<Either<String, Category>> getCategoryById(String id) async {
    try {
      final doc = await firestore.collection('category').doc(id).get();
      if (!doc.exists) return Left('Category not found');
      return Right(Category.fromJson(doc.data()!));
    } catch (e) {
      return Left('Failed to fetch category by ID: $e');
    }
  }
}
