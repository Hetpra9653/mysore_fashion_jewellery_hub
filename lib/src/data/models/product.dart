import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/category.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String? label;
  final bool? isAds;
  final String? productID;
  final String? title;
  final String? description;
  final String? categoryID;
  final List<String>? colorOptions;
  final List<String>? sizeOptions;
  final String? price;
  final String? discountPrice;
  final bool? isFeatured;
  final List<String>? tags;
  final List<String>? images;
  final List<String>? videos;
  final List<Review>? reviews;
  final String? stock;
  @TimestampConverter()
  final DateTime? createdAt; // Use DateTime instead of Timestamp
  @TimestampConverter()
  final DateTime? updatedAt; // Use DateTime instead of Timestamp

  Product({
    this.reviews,
    this.label,
    this.isAds,
    this.productID,
    this.title,
    this.description,
    this.categoryID,
    this.colorOptions,
    this.sizeOptions,
    this.price,
    this.discountPrice,
    this.isFeatured,
    this.tags,
    this.images,
    this.videos,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  /// Creates a copy of this Product with the given fields replaced with new values.
  Product copyWith({
    String? label,
    bool? isAds,
    String? productID,
    String? title,
    String? description,
    String? categoryID,
    List<String>? colorOptions,
    List<String>? sizeOptions,
    String? price,
    String? discountPrice,
    bool? isFeatured,
    List<String>? tags,
    List<String>? images,
    List<String>? videos,
    List<Review>? reviews,
    String? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      label: label ?? this.label,
      isAds: isAds ?? this.isAds,
      productID: productID ?? this.productID,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryID: categoryID ?? this.categoryID,
      colorOptions: colorOptions ?? this.colorOptions,
      sizeOptions: sizeOptions ?? this.sizeOptions,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      reviews: reviews ?? this.reviews,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

///create same for feature model
@JsonSerializable()
class Feature {
  final String? color;
  final String? size;
  final String? material;

  Feature({this.color, this.material, this.size});

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}

///add a model for review and ratings

@JsonSerializable()
class Review {
  final String? reviewID;
  final String? userID;
  final String? review;
  final double? rating;
  final List<String>? images;
  @TimestampConverter()
  final DateTime? createdAt; // Use DateTime instead of Timestamp
  @TimestampConverter()
  final DateTime? updatedAt; // Use DateTime instead of Timestamp

  Review({
    this.reviewID,
    this.images,
    this.userID,
    this.review,
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  /// Creates a copy of this Review with the given fields replaced with new values.
  Review copyWith({
    String? reviewID,
    String? userID,
    String? review,
    double? rating,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imageUrls, // Added for the uploaded image URLs
  }) {
    return Review(
      reviewID: reviewID ?? this.reviewID,
      userID: userID ?? this.userID,
      review: review ?? this.review,
      rating: rating ?? this.rating,
      images: imageUrls ?? images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
