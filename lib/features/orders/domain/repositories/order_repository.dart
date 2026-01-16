import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<Order>>> getOrders(String businessId);
  Future<Either<Failure, void>> createOrder(Order order);
  Future<Either<Failure, void>> updateOrder(Order order);
  Future<Either<Failure, void>> updateOrderStatus(String businessId, String orderId, String status);
}
