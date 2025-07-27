import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';

abstract class ProductEvent {}

class FetchHomeScreenDataEvent extends ProductEvent {}

// Product Events
class FetchAllProductsEvent extends ProductEvent {}

class FetchProductByIdEvent extends ProductEvent {
  final String id;
  FetchProductByIdEvent({required this.id});
}

class FetchProductByCategoryEvent extends ProductEvent {
  final String categoryId;
  FetchProductByCategoryEvent({required this.categoryId});
}

// Category Events
class FetchAllCategoriesEvent extends ProductEvent {}

class FetchCategoryByIdEvent extends ProductEvent {
  final String id;
  FetchCategoryByIdEvent({required this.id});
}

///same for brand same as category

class FetchAllBrandsEvent extends ProductEvent {}
class FetchBrandByIdEvent extends ProductEvent {
  final String id;
  FetchBrandByIdEvent({required this.id});
}


///add review Events
class AddReviewEvent extends ProductEvent {
  final String productId;
  final Review review;

  AddReviewEvent({required this.productId, required this.review});
}

