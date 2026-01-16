import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Order>>> getOrders(String businessId) async {
    try {
      final orders = await _remoteDataSource.getOrders(businessId);
      
      // Fetch customer names
      // We know path: BusinessAccounts/{businessId}/customers/{customerId}
      // Note: businessId arg in getOrders corresponds to the email in our current logic.
      final firestore = FirebaseFirestore.instance;
      
      // Create a list of futures to fetch related data
      final ordersWithNamesFutures = orders.map((orderModel) async {
        String? name;
        String? phone;
        if (orderModel.customerId.isNotEmpty) {
           try {
             final customerDoc = await firestore
                 .collection('BusinessAccounts')
                 .doc(businessId)
                 .collection('customers')
                 .doc(orderModel.customerId)
                 .get();
                 
             if (customerDoc.exists) {
               name = customerDoc.data()?['name'] as String?;
               phone = customerDoc.data()?['phone'] as String?;
             }
           } catch (e) {
             debugPrint('Error fetching customer: $e');
           }
        }

        // Return new Order instance (not Model) with the name
        return Order(
          id: orderModel.id,
          businessId: orderModel.businessId,
          ownerId: orderModel.ownerId,
          customerId: orderModel.customerId,
          customerName: name ?? 'Unknown',
          customerPhone: phone ?? '',
          status: orderModel.status,
          source: orderModel.source,
          address: orderModel.address,
          notes: orderModel.notes,
          orderDate: orderModel.orderDate,
          deliveryDate: orderModel.deliveryDate,
          deliveryCharge: orderModel.deliveryCharge,
          totalAmount: orderModel.totalAmount,
          products: orderModel.products,
        );
      }).toList();

      final fullOrders = await Future.wait(ordersWithNamesFutures);
      fullOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      return Right(fullOrders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createOrder(String businessId, Order order) async {
    try {
      // Convert Entity to Model
      final orderModel = OrderModel(
        id: order.id,
        businessId: order.businessId,
        ownerId: order.ownerId,
        customerId: order.customerId,
        status: order.status,
        source: order.source,
        address: order.address,
        notes: order.notes,
        orderDate: order.orderDate,
        deliveryDate: order.deliveryDate,
        deliveryCharge: order.deliveryCharge,
        totalAmount: order.totalAmount,
        products: order.products
            .map((e) => OrderItemModel(
                  id: e.id,
                  name: e.name,
                  code: e.code,
                  price: e.price,
                  quantity: e.quantity,
                ))
            .toList(),
      );
      await _remoteDataSource.createOrder(businessId, orderModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrder(String businessId, Order order) async {
    try {
      final orderModel = OrderModel(
        id: order.id,
        businessId: order.businessId,
        ownerId: order.ownerId,
        customerId: order.customerId,
        status: order.status,
        source: order.source,
        address: order.address,
        notes: order.notes,
        orderDate: order.orderDate,
        deliveryDate: order.deliveryDate,
        deliveryCharge: order.deliveryCharge,
        totalAmount: order.totalAmount,
        products: order.products
            .map((e) => OrderItemModel(
                  id: e.id,
                  name: e.name,
                  code: e.code,
                  price: e.price,
                  quantity: e.quantity,
                ))
            .toList(),
      );
      await _remoteDataSource.updateOrder(businessId, orderModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(String businessId, String orderId, String status) async {
    try {
      await _remoteDataSource.updateOrderStatus(businessId, orderId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> deleteOrder(String businessId, String orderId) async {
    try {
      await _remoteDataSource.deleteOrder(businessId, orderId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
