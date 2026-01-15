import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:orderly/features/orders/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.businessId,
    required super.ownerId,
    required super.customerId,
    required super.status,
    required super.source,
    required super.address,
    required super.notes,
    required super.orderDate,
    required super.deliveryDate,
    required super.deliveryCharge,
    required super.totalAmount,
    required super.products,
    super.customerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      businessId: json['businessId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      customerId: json['customerId'] ?? '',
      status: json['status'] ?? 'pending',
      source: json['source'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      orderDate: (json['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryDate: (json['deliveryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      customerName: null, // Not stored in order document implies it's joined later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'ownerId': ownerId,
      'customerId': customerId,
      'status': status,
      'source': source,
      'address': address,
      'notes': notes,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'products': products.map((e) {
        if (e is OrderItemModel) {
          return e.toJson();
        }
        // Fallback or convert manually if it's a base OrderItem
        return OrderItemModel(
          id: e.id,
          name: e.name,
          code: e.code,
          price: e.price,
          quantity: e.quantity,
        ).toJson();
      }).toList(),
    };
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.name,
    required super.code,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'price': price,
      'quantity': quantity,
    };
  }
}
