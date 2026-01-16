import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/features/profile/domain/entities/business_profile.dart';

class BusinessProfileModel extends BusinessProfile {
  const BusinessProfileModel({
    required super.userId,
    super.businessId,
    required super.email,
    required super.phone,
    required super.userName,
    super.businessName,
    super.businessAddress,
    super.businessUrl,
    super.whatsapp,
    super.facebook,
    super.youtube,
    required super.plan,
    required super.createdAt,
  });

  factory BusinessProfileModel.fromFirestore(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final businesses = json['businesses'] as List<dynamic>? ?? [];
    
    // Assuming the first business is the primary one for now, as typical for this app
    Map<String, dynamic> business = {};
    if (businesses.isNotEmpty) {
      business = businesses.first as Map<String, dynamic>;
    }

    final socialLinks = business['socialLinks'] as Map<String, dynamic>? ?? {};

    return BusinessProfileModel(
      userId: profile['userId'] ?? '',
      businessId: business['businessId'],
      email: profile['email'] ?? '',
      phone: profile['phone'] ?? business['phone'] ?? '',
      userName: profile['userName'] ?? '',
      businessName: business['businessName'],
      businessAddress: business['businessAddress'],
      businessUrl: business['businessUrl'],
      whatsapp: socialLinks['whatsapp'],
      facebook: socialLinks['facebook'],
      youtube: socialLinks['youtube'],
      plan: business['plan'] ?? 'Lite',
      createdAt: (profile['createdAt'] != null)
          ? (profile['createdAt'] as Timestamp).toDate()
          : (business['createdAt'] != null)
              ? (business['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profile': {
        'userId': userId,
        'email': email,
        'phone': phone,
        'userName': userName,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'businesses': [
        {
          'businessId': businessId,
          'businessName': businessName,
          'phone': phone,
          'plan': plan,
          'businessAddress': businessAddress,
          'businessUrl': businessUrl,
          'createdAt': Timestamp.fromDate(createdAt),
          'socialLinks': {
            'whatsapp': whatsapp,
            'facebook': facebook,
            'youtube': youtube,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }
      ]
    };
  }

  BusinessProfileModel copyWith({
    String? phone,
    String? userName,
    String? businessName,
    String? businessAddress,
    String? businessUrl,
    String? whatsapp,
    String? facebook,
    String? youtube,
  }) {
    return BusinessProfileModel(
      userId: userId,
      businessId: businessId,
      email: email,
      phone: phone ?? this.phone,
      userName: userName ?? this.userName,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessUrl: businessUrl ?? this.businessUrl,
      whatsapp: whatsapp ?? this.whatsapp,
      facebook: facebook ?? this.facebook,
      youtube: youtube ?? this.youtube,
      plan: plan,
      createdAt: createdAt,
    );
  }
}
