import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;

  DashboardCubit({
    required OrderRepository orderRepository,
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
  })  : _orderRepository = orderRepository,
        _customerRepository = customerRepository,
        _productRepository = productRepository,
        super(const DashboardState());

  String get _businessId => FirebaseAuth.instance.currentUser?.email ?? '';

  Future<void> loadDashboard({DashboardFilter? filter}) async {
    final currentFilter = filter ?? state.filter;
    emit(state.copyWith(isLoading: true, filter: currentFilter, clearError: true));

    try {
      // Fetch all data
      final ordersResult = await _orderRepository.getOrders(_businessId);
      final customersResult = await _customerRepository.getCustomers(_businessId);
      await _productRepository.getProducts(_businessId); // Pre-warm or just remove if not needed for stats yet

      ordersResult.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (allOrders) {
          final customers = customersResult.fold((_) => [], (list) => list);
          
          // Apply Date Filtering
          final filteredOrders = _filterOrders(allOrders, currentFilter);
          
          // Calculate Stats
          double revenue = 0;
          int completed = 0;
          final Map<String, int> statusDistribution = {
            'pending': 0,
            'completed': 0,
            'processing': 0,
            'cancelled': 0,
          };

          for (final order in filteredOrders) {
            final status = order.status.toLowerCase();
            if (status != 'cancelled') {
              revenue += order.totalAmount;
            }
            if (status == 'completed') {
              completed++;
            }
            
            if (statusDistribution.containsKey(status)) {
              statusDistribution[status] = statusDistribution[status]! + 1;
            } else {
              statusDistribution['pending'] = (statusDistribution['pending'] ?? 0) + 1;
            }
          }

          // Urgent & At Risk
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final urgent = allOrders.where((o) {
            if (o.status.toLowerCase() == 'completed' || o.status.toLowerCase() == 'cancelled') return false;
            final dDate = DateTime(o.deliveryDate.year, o.deliveryDate.month, o.deliveryDate.day);
            return dDate.isAtSameMomentAs(today);
          }).toList();

          final atRisk = allOrders.where((o) {
            if (o.status.toLowerCase() == 'completed' || o.status.toLowerCase() == 'cancelled') return false;
            final dDate = DateTime(o.deliveryDate.year, o.deliveryDate.month, o.deliveryDate.day);
            return dDate.isBefore(today);
          }).toList();

          // Top Selling Products
          final Map<String, int> productSales = {};
          for (final order in filteredOrders) {
            if (order.status.toLowerCase() == 'cancelled') continue;
            for (final item in order.products) {
              productSales[item.name] = (productSales[item.name] ?? 0) + item.quantity;
            }
          }

          final sortedProducts = productSales.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final maxSales = sortedProducts.isNotEmpty ? sortedProducts.first.value : 1;
          final topProducts = sortedProducts.take(5).map((e) => TopProduct(
            name: e.key,
            soldCount: e.value,
            percentage: e.value / maxSales,
          )).toList();

          emit(state.copyWith(
            isLoading: false,
            totalRevenue: revenue,
            totalOrders: filteredOrders.length,
            totalCustomers: customers.length,
            completedOrders: completed,
            recentOrders: filteredOrders.take(10).toList(),
            urgentOrders: urgent,
            atRiskOrders: atRisk,
            topProducts: topProducts,
            statusCounts: statusDistribution,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  List<Order> _filterOrders(List<Order> orders, DashboardFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (filter) {
      case DashboardFilter.today:
        return orders.where((o) {
          final oDate = DateTime(o.orderDate.year, o.orderDate.month, o.orderDate.day);
          return oDate.isAtSameMomentAs(today);
        }).toList();
      case DashboardFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return orders.where((o) => o.orderDate.isAfter(startOfWeek)).toList();
      case DashboardFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return orders.where((o) => o.orderDate.isAfter(startOfMonth)).toList();
      case DashboardFilter.allTime:
        return orders;
    }
  }
}
