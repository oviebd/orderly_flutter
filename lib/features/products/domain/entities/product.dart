import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String businessId;
  final String ownerId;
  final String name;
  final String code;
  final String details;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.name,
    this.code = '',
    this.details = '',
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        ownerId,
        name,
        code,
        details,
        price,
        createdAt,
        updatedAt,
      ];
}
