import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers(String businessId);
  Future<List<CustomerModel>> searchCustomers(String businessId, String query);
  Future<CustomerModel?> getCustomerById(String businessId, String customerId);
  Future<CustomerModel> createCustomer(String businessId, CustomerModel customer);
  Future<void> updateCustomer(String businessId, CustomerModel customer);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final FirebaseFirestore _firestore;

  CustomerRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CustomerModel>> getCustomers(String businessId) async {
    final snapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<CustomerModel>> searchCustomers(
    String businessId,
    String query,
  ) async {
    if (query.isEmpty) {
      return [];
    }

    // Search by phone number (starts with query)
    final phoneSnapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .where('phone', isGreaterThanOrEqualTo: query)
        .where('phone', isLessThan: '${query}z')
        .limit(10)
        .get();

    final phoneResults = phoneSnapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
        .toList();

    // Also search by name (starts with query) - case insensitive search is limited in Firestore
    // For better search, consider using a dedicated search service like Algolia
    final nameQuery = query.toLowerCase();
    final nameSnapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .limit(50) // Get more to filter client-side
        .get();

    final nameResults = nameSnapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
        .where((customer) =>
            customer.name.toLowerCase().contains(nameQuery) &&
            !phoneResults.any((p) => p.id == customer.id))
        .take(10)
        .toList();

    return [...phoneResults, ...nameResults];
  }

  @override
  Future<CustomerModel?> getCustomerById(
    String businessId,
    String customerId,
  ) async {
    final doc = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .doc(customerId)
        .get();

    if (!doc.exists) return null;
    return CustomerModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<CustomerModel> createCustomer(
    String businessId,
    CustomerModel customer,
  ) async {
    final docRef = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .add(customer.toJson());

    return CustomerModel(
      id: docRef.id,
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

  @override
  Future<void> updateCustomer(
    String businessId,
    CustomerModel customer,
  ) async {
    await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('customers')
        .doc(customer.id)
        .update(customer.toJson());
  }
}
