import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../../domain/entities/order.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders(String businessId);
  Future<void> createOrder(String businessId, OrderModel order);
  Future<void> updateOrder(String businessId, OrderModel order);
  Future<void> updateOrderStatus(String businessId, String orderId, String status);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<OrderModel>> getOrders(String businessId) async {
    // Assuming 'businessData' collection structure as per generic firebase pattern
    // However, PRD mentions 'Orders' collection at root or nested?
    // firebase_db.json: collections -> BusinessAccounts -> ... -> businessData -> orders
    // This structure helps: collectionGroup or specific path?
    // Let's assume a simplified structure for MVP functionality or based on firebase_db.json path.
    // Given the complexity of nested structure in json, often in Firestore we flatten or use subcollections.
    // If we follow json strictly: BusinessAccounts/{email}/businesses/{businessId}/businessData/orders
    // But we need to know email to query.
    // Let's assume we query 'Orders' collection where businessId matches, assuming we Flattened it?
    // Or we will stick to PRD saying "Reuses existing Firestore collections from web app".
    // "Orders" is listed at root in 6.2 Data Model list of collections.
    // So I will query `Orders` collection.
    
    final snapshot = await _firestore
        .collection('BusinessAccounts')
        .doc(businessId) // businessId here is the email
        .collection('orders')
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> createOrder(String businessId, OrderModel order) async {
    // We let Firestore generate ID if order.id is empty, but we might have generated it locally.
    // If id is provided, set.
    // For creation, we need to know the path.
    // businessId here is the email used as the document index in BusinessAccounts
    final path = _firestore.collection('BusinessAccounts').doc(businessId).collection('orders');
    
    if (order.id.isNotEmpty) {
        await path.doc(order.id).set(order.toJson());
    } else {
        await path.add(order.toJson());
    }
  }

  @override
  Future<void> updateOrder(String businessId, OrderModel order) async {
    await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('orders')
        .doc(order.id)
        .update(order.toJson());
  }

  @override
  Future<void> updateOrderStatus(String businessId, String orderId, String status) async {
    await _firestore
        .collection('BusinessAccounts')
        .doc(businessId)
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }
}
