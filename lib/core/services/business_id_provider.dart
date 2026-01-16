import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper class to provide business-related identifiers
class BusinessIdProvider {
  static final BusinessIdProvider _instance = BusinessIdProvider._internal();
  factory BusinessIdProvider() => _instance;
  BusinessIdProvider._internal();

  String? _cachedBusinessId;
  String? _cachedEmail;

  /// Gets the current user's email (used as document path in BusinessAccounts)
  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

  /// Gets the current user's uid (used as ownerId)
  String get ownerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Gets the actual businessId UUID from the businesses array in Firestore
  /// This is cached after the first fetch for the current user
  Future<String> getBusinessId() async {
    final currentEmail = email;
    
    // Return cached value if still valid for the same user
    if (_cachedBusinessId != null && _cachedEmail == currentEmail) {
      return _cachedBusinessId!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('BusinessAccounts')
          .doc(currentEmail)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final businesses = data?['businesses'] as List<dynamic>?;
        if (businesses != null && businesses.isNotEmpty) {
          final firstBusiness = businesses.first as Map<String, dynamic>;
          _cachedBusinessId = firstBusiness['businessId'] as String?;
          _cachedEmail = currentEmail;
          return _cachedBusinessId ?? ownerId;
        }
      }
    } catch (e) {
      // Fall back to ownerId on error
    }

    // Fall back to ownerId if no businessId found
    return ownerId;
  }

  /// Clears the cached businessId (call this on logout)
  void clearCache() {
    _cachedBusinessId = null;
    _cachedEmail = null;
  }
}
