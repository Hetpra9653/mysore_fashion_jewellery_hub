// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
  label: json['label'] as String?,
  isAds: json['isAds'] as bool?,
  productID: json['productID'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  categoryID: json['categoryID'] as String?,
  colorOptions:
      (json['colorOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  sizeOptions:
      (json['sizeOptions'] as List<dynamic>?)?.map((e) => e as String).toList(),
  price: json['price'] as String?,
  discountPrice: json['discountPrice'] as String?,
  isFeatured: json['isFeatured'] as bool?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  videos: (json['videos'] as List<dynamic>?)?.map((e) => e as String).toList(),
  stock: json['stock'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp?,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'label': instance.label,
  'isAds': instance.isAds,
  'productID': instance.productID,
  'title': instance.title,
  'description': instance.description,
  'categoryID': instance.categoryID,
  'colorOptions': instance.colorOptions,
  'sizeOptions': instance.sizeOptions,
  'price': instance.price,
  'discountPrice': instance.discountPrice,
  'isFeatured': instance.isFeatured,
  'tags': instance.tags,
  'images': instance.images,
  'videos': instance.videos,
  'reviews': instance.reviews,
  'stock': instance.stock,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
  color: json['color'] as String?,
  material: json['material'] as String?,
  size: json['size'] as String?,
);

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
  'color': instance.color,
  'size': instance.size,
  'material': instance.material,
};

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  reviewID: json['reviewID'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  userID: json['userID'] as String?,
  review: json['review'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp?,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'reviewID': instance.reviewID,
  'userID': instance.userID,
  'review': instance.review,
  'rating': instance.rating,
  'images': instance.images,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
