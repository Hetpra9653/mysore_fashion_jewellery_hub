// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brands.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brands _$BrandsFromJson(Map<String, dynamic> json) => Brands(
  brandsImage: json['brandsImage'] as String?,
  brandsID: json['brandsID'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$BrandsToJson(Brands instance) => <String, dynamic>{
  'brandsID': instance.brandsID,
  'name': instance.name,
  'brandsImage': instance.brandsImage,
  'description': instance.description,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
