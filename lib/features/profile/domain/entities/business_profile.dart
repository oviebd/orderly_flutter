import 'package:equatable/equatable.dart';

class BusinessProfile extends Equatable {
  final String userId;
  final String? businessId;
  final String email;
  final String phone;
  final String userName;
  final String? businessName;
  final String? businessAddress;
  final String? businessUrl;
  final String? whatsapp;
  final String? facebook;
  final String? youtube;
  final String plan;
  final DateTime createdAt;

  const BusinessProfile({
    required this.userId,
    this.businessId,
    required this.email,
    required this.phone,
    required this.userName,
    this.businessName,
    this.businessAddress,
    this.businessUrl,
    this.whatsapp,
    this.facebook,
    this.youtube,
    required this.plan,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        userId,
        businessId,
        email,
        phone,
        userName,
        businessName,
        businessAddress,
        businessUrl,
        whatsapp,
        facebook,
        youtube,
        plan,
        createdAt,
      ];
}
