import 'package:mysore_fashion_jewellery_hub/src/data/models/brands.dart';

import '../../../data/models/category.dart';
import '../../../data/models/product.dart';

abstract class ProductState {}

// Initial
class ProductInitial extends ProductState {}

// Product States
class ProductLoading extends ProductState {}

class ProductListLoaded extends ProductState {
  final List<Product> products;
  ProductListLoaded({required this.products});
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  ProductDetailLoaded({required this.product});
}

class ProductError extends ProductState {
  final String message;
  ProductError({required this.message});
}

class CarouselImagesLoaded extends ProductState {
  final List<String> carouselImages;

  CarouselImagesLoaded({required this.carouselImages});
}

// Category States
class CategoryLoading extends ProductState {}

class CategoryListLoaded extends ProductState {
  final List<Category> categories;
  CategoryListLoaded({required this.categories});
}

class CategoryDetailLoaded extends ProductState {
  final Category category;
  CategoryDetailLoaded({required this.category});
}

class CategoryError extends ProductState {
  final String message;
  CategoryError({required this.message});
}

///fetch brand

class BrandLoading extends ProductState {}

class BrandListLoaded extends ProductState {
  final List<Brands> brands;
  BrandListLoaded({required this.brands});
}

// Add Review States
class AddReviewLoading extends ProductState {}

class AddReviewSuccess extends ProductState {
  final Product product;
  AddReviewSuccess({required this.product});
}
