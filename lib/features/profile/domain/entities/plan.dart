import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final String id;
  final String name;
  final double price;
  final PlanCapabilities capabilities;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.capabilities,
  });

  @override
  List<Object?> get props => [id, name, price, capabilities];
}

class PlanCapabilities extends Equatable {
  final int maxCustomerNumber;
  final int maxOrderNumber;
  final int maxProductNumber;
  final bool canAddOrder;
  final bool canAddCustomer;
  final bool canAddProducts;
  final bool hasExportImportOption;

  const PlanCapabilities({
    required this.maxCustomerNumber,
    required this.maxOrderNumber,
    required this.maxProductNumber,
    required this.canAddOrder,
    required this.canAddCustomer,
    required this.canAddProducts,
    required this.hasExportImportOption,
  });

  @override
  List<Object?> get props => [
        maxCustomerNumber,
        maxOrderNumber,
        maxProductNumber,
        canAddOrder,
        canAddCustomer,
        canAddProducts,
        hasExportImportOption,
      ];
}
