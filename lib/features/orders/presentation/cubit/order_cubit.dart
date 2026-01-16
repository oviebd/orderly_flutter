import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit(this._orderRepository) : super(OrderInitial());

  Future<void> fetchOrders(String businessId) async {
    emit(OrderLoading());
    final result = await _orderRepository.getOrders(businessId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrderLoaded(orders)),
    );
  }

  Future<void> createOrder(Order order) async {
    // We assume optimistic update or re-fetch. Ideally re-fetch or add to list.
    emit(OrderLoading());
    final result = await _orderRepository.createOrder(order.businessId, order);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (_) {
        // Success
        // After creating, we might want to refresh list.
        fetchOrders(order.businessId);
      },
    );
  }

  Future<void> updateStatus(String orderId, String status, String businessId) async {
    final result = await _orderRepository.updateOrderStatus(businessId, orderId, status);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (_) => fetchOrders(businessId), // Refresh
    );
  }

  Future<void> deleteOrder(String orderId, String businessId) async {
    final result = await _orderRepository.deleteOrder(businessId, orderId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (_) => fetchOrders(businessId), // Refresh
    );
  }
}
