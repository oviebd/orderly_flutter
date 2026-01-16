import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/features/profile/data/models/business_profile_model.dart';
import 'package:orderly/features/profile/data/models/plan_model.dart';

abstract class ProfileRemoteDataSource {
  Future<BusinessProfileModel> getProfile(String email);
  Future<void> updateProfile(String email, BusinessProfileModel profile);
  Future<List<PlanModel>> getPlans();
  Future<void> updatePlan(String email, String planId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl(this._firestore);

  @override
  Future<BusinessProfileModel> getProfile(String email) async {
    final doc = await _firestore.collection('BusinessAccounts').doc(email).get();
    if (doc.exists) {
      return BusinessProfileModel.fromFirestore(doc.data()!);
    } else {
      throw Exception('Profile not found');
    }
  }

  @override
  Future<void> updateProfile(String email, BusinessProfileModel profile) async {
    final doc = await _firestore.collection('BusinessAccounts').doc(email).get();
    
    if (doc.exists) {
      final existingData = doc.data()!;
      final businesses = List<Map<String, dynamic>>.from(existingData['businesses'] ?? []);
      
      // Update profile info
      final updatedProfileMap = Map<String, dynamic>.from(existingData['profile'] ?? {});
      updatedProfileMap.addAll({
        'userName': profile.userName,
        'phone': profile.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update business info (assuming first business)
      if (businesses.isNotEmpty) {
        final business = Map<String, dynamic>.from(businesses[0]);
        business.addAll({
          'businessName': profile.businessName,
          'phone': profile.phone,
          'businessAddress': profile.businessAddress,
          'businessUrl': profile.businessUrl,
          'socialLinks': {
            'whatsapp': profile.whatsapp,
            'facebook': profile.facebook,
            'youtube': profile.youtube,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        });
        businesses[0] = business;
      }

      await _firestore.collection('BusinessAccounts').doc(email).update({
        'profile': updatedProfileMap,
        'businesses': businesses,
      });
    } else {
      // Fallback if document doesn't exist (though it should)
      await _firestore.collection('BusinessAccounts').doc(email).set(
        profile.toFirestore(),
        SetOptions(merge: true),
      );
    }
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    final snapshot = await _firestore.collection('Plan').get();
    final plans = snapshot.docs
        .map((doc) => PlanModel.fromFirestore(doc.data(), doc.id))
        .toList();
    
    // Sort by price low to high
    plans.sort((a, b) => a.price.compareTo(b.price));
    return plans;
  }

  @override
  Future<void> updatePlan(String email, String planId) async {
    // Updating plan in the first business
    final doc = await _firestore.collection('BusinessAccounts').doc(email).get();
    if (doc.exists) {
      final data = doc.data()!;
      final businesses = List<Map<String, dynamic>>.from(data['businesses'] ?? []);
      if (businesses.isNotEmpty) {
        businesses[0]['plan'] = planId;
        businesses[0]['updatedAt'] = FieldValue.serverTimestamp();
        
        await _firestore.collection('BusinessAccounts').doc(email).update({
          'businesses': businesses,
        });
      }
    }
  }
}
