part of 'customers_cubit.dart';

class CustomersState extends Equatable {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  bool get isEmpty => customers.isEmpty && !isLoading;
  bool get hasCustomers => customers.isNotEmpty;

  CustomersState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearch ? '' : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [customers, isLoading, error, searchQuery];
}
