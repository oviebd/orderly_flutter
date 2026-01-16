import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.businessId,
    required super.ownerId,
    required super.name,
    super.code,
    super.details,
    required super.price,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      businessId: json['businessId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? json['productName'] ?? '',
      code: json['code'] ?? '',
      details: json['details'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'ownerId': ownerId,
      'name': name,
      'productName': name,
      'code': code,
      'details': details,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a ProductModel from a Product entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      businessId: product.businessId,
      ownerId: product.ownerId,
      name: product.name,
      code: product.code,
      details: product.details,
      price: product.price,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
