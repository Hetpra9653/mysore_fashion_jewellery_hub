import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String? categoryID;
  final String? name;
  final String? categoryImage;
  final String? description;

  @TimestampConverter()
  final DateTime? createdAt; // Use DateTime instead of Timestamp

  Category({
    this.categoryImage,
    this.categoryID,
    this.name,
    this.description,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
}
