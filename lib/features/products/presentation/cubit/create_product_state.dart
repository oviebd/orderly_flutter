part of 'create_product_cubit.dart';

class CreateProductState extends Equatable {
  final String name;
  final String code;
  final double price;
  final String details;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;
  final Product? createdProduct;

  const CreateProductState({
    this.name = '',
    this.code = '',
    this.price = 0.0,
    this.details = '',
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
    this.createdProduct,
  });

  bool get isValid => name.isNotEmpty && price > 0;

  CreateProductState copyWith({
    String? name,
    String? code,
    double? price,
    String? details,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? isSuccess,
    Product? createdProduct,
  }) {
    return CreateProductState(
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      details: details ?? this.details,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      createdProduct: createdProduct ?? this.createdProduct,
    );
  }

  @override
  List<Object?> get props => [
        name,
        code,
        price,
        details,
        isSubmitting,
        error,
        isSuccess,
        createdProduct,
      ];
}
