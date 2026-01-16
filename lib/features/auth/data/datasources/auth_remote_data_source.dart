import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

abstract class AuthRemoteDataSource {
  Future<void> signIn(String email, String password);
  Future<void> signUp({
    required String email,
    required String password,
    required String userName,
    String phone,
  });
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
  Future<bool> checkHasBusiness(String email);
  Future<void> registerBusiness({
    required String email,
    required String businessName,
    required String phone,
    required String userId,
    required String userName,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, [FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String userName,
    String phone = '',
  }) async {
    // Create Firebase Auth user
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user document in Firestore
    final userId = credential.user!.uid;
    await _firestore.collection('users').doc(userId).set({
      'id': userId,
      'email': email,
      'userName': userName,
      'phone': phone,
      'role': 'business',
      'status': 'enabled',
      'createdAt': FieldValue.serverTimestamp(),
      'businessName': '',
      'plan': 'free',
      'canCreateOrders': true,
    });
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<bool> checkHasBusiness(String email) async {
    try {
      final doc = await _firestore.collection('BusinessAccounts').doc(email).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final businesses = data['businesses'] as List<dynamic>?;
      return businesses != null && businesses.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> registerBusiness({
    required String email,
    required String businessName,
    required String phone,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now().toIso8601String();
    final businessId = const Uuid().v4();

    final docRef = _firestore.collection('BusinessAccounts').doc(email);

    await docRef.set({
      'profile': {
        'userId': userId,
        'email': email,
        'phone': phone,
        'userName': userName,
        'createdAt': now,
        'updatedAt': now,
      },
      'businesses': [
        {
          'businessId': businessId,
          'businessName': businessName,
          'phone': phone,
          'plan': 'Lite',
          'businessAddress': '',
          'businessUrl': '',
          'createdAt': now,
          'socialLinks': {
            'whatsapp': '',
            'facebook': '',
            'youtube': '',
          },
        }
      ],
      'businessPlan': {
        'name': 'Lite',
        'price': 0,
        'currency': 'BDT',
      },
      'capabilities': {
        'maxCustomerNumber': 50,
        'maxOrderNumber': 50,
        'maxProductNumber': 20,
        'canAddOrder': true,
        'canAddCustomer': true,
        'canAddProducts': true,
        'hasExportImportOption': false,
      },
    });

    // Update user document with business name
    await _firestore.collection('users').doc(userId).update({
      'businessName': businessName,
    });
  }
}
