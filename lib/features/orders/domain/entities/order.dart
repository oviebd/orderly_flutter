import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String businessId;
  final String ownerId;
  final String customerId;
  final String status; // pending, completed, etc.
  final String source; // whatsapp, messenger
  final String address;
  final String notes;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final double deliveryCharge;
  final double totalAmount;
  final List<OrderItem> products;
  final String? customerName;

  const Order({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.customerId,
    this.customerName, // Optional, fetched separately
    required this.status,
    required this.source,
    required this.address,
    required this.notes,
    required this.orderDate,
    required this.deliveryDate,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.products,
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        ownerId,
        customerId,
        status,
        source,
        address,
        notes,
        orderDate,
        deliveryDate,
        deliveryCharge,
        totalAmount,
        products,
        customerName,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String name;
  final String code;
  final double price;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [id, name, code, price, quantity];
}
