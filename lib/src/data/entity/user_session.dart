import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

import '../models/category.dart';

class UserSession {
  List<Product> products = [];
  List<Category> categories = [];
  UserModel? user;

  ///set userId
  void setUserId(String userId) {
    if (user != null) {
      user!.userID = userId;
    }
  }

  ///set user
  void setUser(UserModel user) {
    this.user = user;
  }

  ///set products
  void setProducts(List<Product> products) {
    this.products = products;
  }

  ///set categories
  void setCategories(List<Category> categories) {
    this.categories = categories;
  }
}
