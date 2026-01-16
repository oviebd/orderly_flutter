import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.phone,
    super.email,
    super.address,
    super.comment,
    super.rating,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a CustomerModel from a Customer entity
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      ownerId: customer.ownerId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      comment: customer.comment,
      rating: customer.rating,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }
}
