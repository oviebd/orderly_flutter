part of 'create_order_cubit.dart';

/// Order source options
enum OrderSource {
  whatsapp('WhatsApp'),
  messenger('Messenger'),
  phone('Phone');

  final String displayName;
  const OrderSource(this.displayName);
}

/// Represents a product item in the order form
class OrderProductItem extends Equatable {
  final String? productId; // null if new product
  final String name;
  final String code;
  final String details;
  final double price;
  final int quantity;

  const OrderProductItem({
    this.productId,
    required this.name,
    this.code = '',
    this.details = '',
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  OrderProductItem copyWith({
    String? productId,
    String? name,
    String? code,
    String? details,
    double? price,
    int? quantity,
  }) {
    return OrderProductItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      code: code ?? this.code,
      details: details ?? this.details,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, name, code, details, price, quantity];
}

/// Selected customer state
class SelectedCustomer extends Equatable {
  final String? customerId; // null if new customer
  final String phone;
  final String name;
  final String address;
  final bool isExisting;

  const SelectedCustomer({
    this.customerId,
    required this.phone,
    required this.name,
    this.address = '',
    this.isExisting = false,
  });

  SelectedCustomer copyWith({
    String? customerId,
    String? phone,
    String? name,
    String? address,
    bool? isExisting,
  }) {
    return SelectedCustomer(
      customerId: customerId ?? this.customerId,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      address: address ?? this.address,
      isExisting: isExisting ?? this.isExisting,
    );
  }

  @override
  List<Object?> get props => [customerId, phone, name, address, isExisting];
}

/// Main state for create order form
class CreateOrderState extends Equatable {
  final SelectedCustomer? selectedCustomer;
  final List<Customer> customerSearchResults;
  final bool isSearchingCustomers;
  
  final OrderSource orderSource;
  
  final List<OrderProductItem> products;
  final List<Product> productSearchResults;
  final bool isSearchingProducts;
  
  final double deliveryCharge;
  
  final DateTime orderDate;
  final TimeOfDay? orderTime;
  final DateTime deliveryDate;
  final TimeOfDay? deliveryTime;
  
  final String notes;
  
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;
  final Order? existingOrder;
  final bool isEditing;

  const CreateOrderState({
    this.selectedCustomer,
    this.customerSearchResults = const [],
    this.isSearchingCustomers = false,
    this.orderSource = OrderSource.whatsapp,
    this.products = const [],
    this.productSearchResults = const [],
    this.isSearchingProducts = false,
    this.deliveryCharge = 0.0,
    required this.orderDate,
    this.orderTime,
    required this.deliveryDate,
    this.deliveryTime,
    this.notes = '',
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
    this.existingOrder,
    this.isEditing = false,
  });

  factory CreateOrderState.initial() {
    final now = DateTime.now();
    return CreateOrderState(
      orderDate: now,
      deliveryDate: now.add(const Duration(days: 1)),
    );
  }

  double get productsTotalPrice =>
      products.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount => productsTotalPrice + deliveryCharge;

  bool get isValid =>
      selectedCustomer != null &&
      selectedCustomer!.phone.isNotEmpty &&
      selectedCustomer!.name.isNotEmpty &&
      products.isNotEmpty &&
      products.every((p) => p.name.isNotEmpty && p.price > 0);

  CreateOrderState copyWith({
    SelectedCustomer? selectedCustomer,
    bool clearCustomer = false,
    List<Customer>? customerSearchResults,
    bool? isSearchingCustomers,
    OrderSource? orderSource,
    List<OrderProductItem>? products,
    List<Product>? productSearchResults,
    bool? isSearchingProducts,
    double? deliveryCharge,
    DateTime? orderDate,
    TimeOfDay? orderTime,
    bool clearOrderTime = false,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
    bool clearDeliveryTime = false,
    String? notes,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? isSuccess,
    Order? existingOrder,
    bool? isEditing,
  }) {
    return CreateOrderState(
      selectedCustomer: clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      customerSearchResults: customerSearchResults ?? this.customerSearchResults,
      isSearchingCustomers: isSearchingCustomers ?? this.isSearchingCustomers,
      orderSource: orderSource ?? this.orderSource,
      products: products ?? this.products,
      productSearchResults: productSearchResults ?? this.productSearchResults,
      isSearchingProducts: isSearchingProducts ?? this.isSearchingProducts,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      orderDate: orderDate ?? this.orderDate,
      orderTime: clearOrderTime ? null : (orderTime ?? this.orderTime),
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: clearDeliveryTime ? null : (deliveryTime ?? this.deliveryTime),
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      existingOrder: existingOrder ?? this.existingOrder,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
        selectedCustomer,
        customerSearchResults,
        isSearchingCustomers,
        orderSource,
        products,
        productSearchResults,
        isSearchingProducts,
        deliveryCharge,
        orderDate,
        orderTime,
        deliveryDate,
        deliveryTime,
        notes,
        isSubmitting,
        error,
        isSuccess,
        existingOrder,
        isEditing,
      ];
}
