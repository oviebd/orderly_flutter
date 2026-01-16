part of 'products_cubit.dart';

class ProductsState extends Equatable {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  bool get isEmpty => products.isEmpty && !isLoading;
  bool get hasProducts => products.isNotEmpty;

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearch ? '' : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [products, isLoading, error, searchQuery];
}
