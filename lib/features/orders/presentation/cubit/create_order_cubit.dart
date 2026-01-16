import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/core/services/business_id_provider.dart';

import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

part 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final BusinessIdProvider _businessIdProvider = BusinessIdProvider();

  CreateOrderCubit({
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
  })  : _customerRepository = customerRepository,
        _productRepository = productRepository,
        _orderRepository = orderRepository,
        super(CreateOrderState.initial());

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? '';

  String get _ownerId =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  void initForEdit(Order order) async {
    final productsList = order.products
        .map((p) => OrderProductItem(
              productId: p.id,
              name: p.name,
              code: p.code,
              price: p.price,
              quantity: p.quantity,
            ))
        .toList();

    OrderSource source;
    try {
      source = OrderSource.values.firstWhere(
        (e) => e.name.toLowerCase() == order.source.toLowerCase(),
        orElse: () => OrderSource.whatsapp,
      );
    } catch (_) {
      source = OrderSource.whatsapp;
    }

    emit(state.copyWith(
      selectedCustomer: SelectedCustomer(
        customerId: order.customerId,
        phone: '', // Will update after fetch
        name: order.customerName ?? '',
        address: order.address,
        isExisting: true,
      ),
      orderSource: source,
      products: productsList,
      deliveryCharge: order.deliveryCharge,
      status: order.status,
      orderDate: order.orderDate,
      orderTime: TimeOfDay(hour: order.orderDate.hour, minute: order.orderDate.minute),
      deliveryDate: order.deliveryDate,
      deliveryTime: TimeOfDay(hour: order.deliveryDate.hour, minute: order.deliveryDate.minute),
      notes: order.notes,
      existingOrder: order,
      isEditing: true,
    ));

    // Fetch full customer details to get phone number
    final customerResult = await _customerRepository.getCustomerById(_email, order.customerId);
    customerResult.fold(
      (failure) => emit(state.copyWith(error: 'Failed to load customer details: ${failure.message}')),
      (customer) {
        if (customer != null) {
          emit(state.copyWith(
            selectedCustomer: state.selectedCustomer?.copyWith(
              phone: customer.phone,
              name: customer.name,
              address: customer.address,
            ),
          ));
        }
      },
    );
  }

  // ==================== Customer Methods ====================

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(customerSearchResults: [], isSearchingCustomers: false));
      return;
    }

    emit(state.copyWith(isSearchingCustomers: true));
    
    final result = await _customerRepository.searchCustomers(_email, query);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isSearchingCustomers: false,
        error: failure.message,
      )),
      (customers) => emit(state.copyWith(
        customerSearchResults: customers,
        isSearchingCustomers: false,
      )),
    );
  }

  void selectExistingCustomer(Customer customer) {
    emit(state.copyWith(
      selectedCustomer: SelectedCustomer(
        customerId: customer.id,
        phone: customer.phone,
        name: customer.name,
        address: customer.address,
        isExisting: true,
      ),
      customerSearchResults: [],
    ));
  }

  void setNewCustomer({
    required String phone,
    required String name,
    String address = '',
  }) {
    emit(state.copyWith(
      selectedCustomer: SelectedCustomer(
        phone: phone,
        name: name,
        address: address,
        isExisting: false,
      ),
    ));
  }

  void updateCustomerPhone(String phone) {
    if (state.selectedCustomer == null) {
      emit(state.copyWith(
        selectedCustomer: SelectedCustomer(phone: phone, name: ''),
      ));
    } else if (!state.selectedCustomer!.isExisting) {
      emit(state.copyWith(
        selectedCustomer: state.selectedCustomer!.copyWith(phone: phone),
      ));
    } else {
      // If existing customer, clear and start fresh
      emit(state.copyWith(
        selectedCustomer: SelectedCustomer(phone: phone, name: ''),
      ));
    }
    searchCustomers(phone);
  }

  void updateCustomerName(String name) {
    if (state.selectedCustomer != null && !state.selectedCustomer!.isExisting) {
      emit(state.copyWith(
        selectedCustomer: state.selectedCustomer!.copyWith(name: name),
      ));
    }
  }

  void updateCustomerAddress(String address) {
    if (state.selectedCustomer != null) {
      emit(state.copyWith(
        selectedCustomer: state.selectedCustomer!.copyWith(address: address),
      ));
    }
  }

  void clearCustomer() {
    emit(state.copyWith(clearCustomer: true, customerSearchResults: []));
  }

  // ==================== Order Source Methods ====================

  void setOrderSource(OrderSource source) {
    emit(state.copyWith(orderSource: source));
  }

  // ==================== Product Methods ====================

  Future<void> searchProducts(String query) async {
    emit(state.copyWith(isSearchingProducts: true));
    
    final result = await _productRepository.searchProducts(_email, query);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isSearchingProducts: false,
        error: failure.message,
      )),
      (products) => emit(state.copyWith(
        productSearchResults: products,
        isSearchingProducts: false,
      )),
    );
  }

  void addProduct(OrderProductItem product) {
    emit(state.copyWith(
      products: [...state.products, product],
      productSearchResults: [],
    ));
  }

  void addEmptyProduct() {
    addProduct(const OrderProductItem(
      name: '',
      price: 0.0,
      quantity: 1,
    ));
  }

  void updateProduct(int index, OrderProductItem product) {
    if (index < 0 || index >= state.products.length) return;
    
    final updated = [...state.products];
    updated[index] = product;
    emit(state.copyWith(products: updated));
  }

  void removeProduct(int index) {
    if (index < 0 || index >= state.products.length) return;
    
    final updated = [...state.products];
    updated.removeAt(index);
    emit(state.copyWith(products: updated));
  }

  void selectProductFromSearch(int productIndex, Product product) {
    if (productIndex < 0 || productIndex >= state.products.length) return;
    
    final currentProduct = state.products[productIndex];
    updateProduct(
      productIndex,
      currentProduct.copyWith(
        productId: product.id,
        name: product.name,
        code: product.code,
        details: product.details,
        price: product.price,
      ),
    );
    emit(state.copyWith(productSearchResults: []));
  }

  void updateProductQuantity(int index, int quantity) {
    if (index < 0 || index >= state.products.length) return;
    if (quantity < 1) return;
    
    updateProduct(index, state.products[index].copyWith(quantity: quantity));
  }

  void incrementProductQuantity(int index) {
    if (index < 0 || index >= state.products.length) return;
    updateProductQuantity(index, state.products[index].quantity + 1);
  }

  void decrementProductQuantity(int index) {
    if (index < 0 || index >= state.products.length) return;
    if (state.products[index].quantity > 1) {
      updateProductQuantity(index, state.products[index].quantity - 1);
    }
  }

  // ==================== Pricing Methods ====================

  void setDeliveryCharge(double charge) {
    emit(state.copyWith(deliveryCharge: charge));
  }

  // ==================== Date/Time Methods ====================

  void setOrderDate(DateTime date) {
    emit(state.copyWith(orderDate: date));
  }

  void setOrderTime(TimeOfDay? time) {
    if (time == null) {
      emit(state.copyWith(clearOrderTime: true));
    } else {
      emit(state.copyWith(orderTime: time));
    }
  }

  void setDeliveryDate(DateTime date) {
    emit(state.copyWith(deliveryDate: date));
  }

  void setDeliveryTime(TimeOfDay? time) {
    if (time == null) {
      emit(state.copyWith(clearDeliveryTime: true));
    } else {
      emit(state.copyWith(deliveryTime: time));
    }
  }

  // ==================== Notes Methods ====================

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  void setOrderStatus(String status) {
    emit(state.copyWith(status: status));
  }

  // ==================== Submit Methods ====================

  Future<void> submitOrder() async {
    if (!state.isValid) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      // Get the actual businessId from Firestore
      final businessId = await _businessIdProvider.getBusinessId();

      // Create new customer if needed
      String customerId = state.selectedCustomer!.customerId ?? '';
      
      if (!state.selectedCustomer!.isExisting) {
        final customerResult = await _customerRepository.createCustomer(
          _email,
          Customer(
            id: '',
            businessId: businessId,
            ownerId: _ownerId,
            name: state.selectedCustomer!.name,
            phone: state.selectedCustomer!.phone,
            address: state.selectedCustomer!.address,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final created = customerResult.fold(
          (failure) => throw Exception(failure.message),
          (customer) => customer,
        );
        customerId = created.id;
      }

      // Build order datetime with optional time
      DateTime orderDateTime = state.orderDate;
      if (state.orderTime != null) {
        orderDateTime = DateTime(
          state.orderDate.year,
          state.orderDate.month,
          state.orderDate.day,
          state.orderTime!.hour,
          state.orderTime!.minute,
        );
      }

      DateTime deliveryDateTime = state.deliveryDate;
      if (state.deliveryTime != null) {
        deliveryDateTime = DateTime(
          state.deliveryDate.year,
          state.deliveryDate.month,
          state.deliveryDate.day,
          state.deliveryTime!.hour,
          state.deliveryTime!.minute,
        );
      }

      // Create order
      final order = Order(
        id: state.isEditing ? state.existingOrder!.id : '',
        businessId: businessId,
        ownerId: _ownerId,
        customerId: customerId,
        customerName: state.selectedCustomer!.name,
        status: state.status,
        source: state.orderSource.name,
        address: state.selectedCustomer!.address,
        notes: state.notes,
        orderDate: orderDateTime,
        deliveryDate: deliveryDateTime,
        deliveryCharge: state.deliveryCharge,
        totalAmount: state.totalAmount,
        products: state.products
            .map((p) => OrderItem(
                  id: p.productId ?? '',
                  name: p.name,
                  code: p.code,
                  price: p.price,
                  quantity: p.quantity,
                ))
            .toList(),
      );

      final result = state.isEditing
          ? await _orderRepository.updateOrder(order)
          : await _orderRepository.createOrder(order);

      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          error: failure.message,
        )),
        (_) => emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
