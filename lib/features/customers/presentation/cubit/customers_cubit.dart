import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomerRepository _customerRepository;

  CustomersCubit({
    required CustomerRepository customerRepository,
  })  : _customerRepository = customerRepository,
        super(const CustomersState());

  String get _businessId => FirebaseAuth.instance.currentUser?.email ?? '';

  Future<void> loadCustomers() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _customerRepository.getCustomers(_businessId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (customers) => emit(state.copyWith(
        isLoading: false,
        customers: customers,
      )),
    );
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      loadCustomers();
      return;
    }

    emit(state.copyWith(isLoading: true, searchQuery: query));

    final result = await _customerRepository.searchCustomers(_businessId, query);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (customers) => emit(state.copyWith(
        isLoading: false,
        customers: customers,
      )),
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', clearSearch: true));
    loadCustomers();
  }

  void addCustomerToList(Customer customer) {
    final updated = [customer, ...state.customers];
    emit(state.copyWith(customers: updated));
  }
}
