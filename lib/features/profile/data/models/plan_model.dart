import 'package:orderly/features/profile/domain/entities/plan.dart';

class PlanModel extends Plan {
  const PlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.capabilities,
  });

  factory PlanModel.fromFirestore(Map<String, dynamic> json, String id) {
    final caps = json['capabilities'] as Map<String, dynamic>? ?? {};
    return PlanModel(
      id: id,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      capabilities: PlanCapabilities(
        maxCustomerNumber: caps['maxCustomerNumber'] ?? 0,
        maxOrderNumber: caps['maxOrderNumber'] ?? 0,
        maxProductNumber: caps['maxProductNumber'] ?? 0,
        canAddOrder: caps['canAddOrder'] ?? false,
        canAddCustomer: caps['canAddCustomer'] ?? false,
        canAddProducts: caps['canAddProducts'] ?? false,
        hasExportImportOption: caps['hasExportImportOption'] ?? false,
      ),
    );
  }
}
