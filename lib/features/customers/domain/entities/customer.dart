import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.comment = '',
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        phone,
        email,
        address,
        comment,
        rating,
        createdAt,
        updatedAt,
      ];
}
