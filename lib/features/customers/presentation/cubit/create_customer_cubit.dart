import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

part 'create_customer_state.dart';

class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  final CustomerRepository _customerRepository;

  CreateCustomerCubit({
    required CustomerRepository customerRepository,
  })  : _customerRepository = customerRepository,
        super(const CreateCustomerState());

  String get _businessId => FirebaseAuth.instance.currentUser?.email ?? '';
  String get _ownerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  void setPhone(String phone) {
    emit(state.copyWith(phone: phone));
  }

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setAddress(String address) {
    emit(state.copyWith(address: address));
  }

  void setComment(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> submitCustomer() async {
    if (!state.isValid) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final customer = Customer(
        id: '',
        ownerId: _ownerId,
        name: state.name,
        phone: state.phone,
        email: state.email,
        address: state.address,
        comment: state.comment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _customerRepository.createCustomer(_businessId, customer);

      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          error: failure.message,
        )),
        (created) => emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          createdCustomer: created,
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
