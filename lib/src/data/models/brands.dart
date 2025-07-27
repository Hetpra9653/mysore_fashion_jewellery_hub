import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'brands.g.dart';

@JsonSerializable()
class Brands {
  final String? brandsID;
  final String? name;
  final String? brandsImage;
  final String? description;

  @TimestampConverter()
  final DateTime? createdAt; // Use DateTime instead of Timestamp

  Brands({
    this.brandsImage,
    this.brandsID,
    this.name,
    this.description,
    this.createdAt,
  });

  factory Brands.fromJson(Map<String, dynamic> json) => _$BrandsFromJson(json);

  Map<String, dynamic> toJson() => _$BrandsToJson(this);
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
