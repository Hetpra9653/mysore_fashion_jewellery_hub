// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  categoryImage: json['categoryImage'] as String?,
  categoryID: json['categoryID'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'categoryID': instance.categoryID,
  'name': instance.name,
  'categoryImage': instance.categoryImage,
  'description': instance.description,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
