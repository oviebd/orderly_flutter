import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(String businessId);
  Future<List<ProductModel>> searchProducts(String businessId, String query);
  Future<ProductModel?> getProductById(String businessId, String productId);
  Future<ProductModel> createProduct(String businessId, ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ProductModel>> getProducts(String businessId) async {
    final snapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String businessId,
    String query,
  ) async {
    if (query.isEmpty) {
      // Return all products when no query
      final snapshot = await _firestore
          .collection('BusinessAccounts')
          .doc(businessId)
          .collection('products')
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .toList();
    }

    final queryLower = query.toLowerCase();

    // Get products and filter client-side for flexible search
    final snapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('products')
        .limit(100)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
        .where((product) =>
            product.name.toLowerCase().contains(queryLower) ||
            product.code.toLowerCase().contains(queryLower))
        .take(20)
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(
    String businessId,
    String productId,
  ) async {
    final doc = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('products')
        .doc(productId)
        .get();

    if (!doc.exists) return null;
    return ProductModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<ProductModel> createProduct(
    String businessId,
    ProductModel product,
  ) async {
    final docRef = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('products')
        .add(product.toJson());

    return ProductModel(
      id: docRef.id,
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
