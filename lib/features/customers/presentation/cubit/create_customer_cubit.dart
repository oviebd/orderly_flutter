import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/core/services/business_id_provider.dart';

import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

part 'create_customer_state.dart';

class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  final CustomerRepository _customerRepository;
  final BusinessIdProvider _businessIdProvider = BusinessIdProvider();

  CreateCustomerCubit({
    required CustomerRepository customerRepository,
  })  : _customerRepository = customerRepository,
        super(const CreateCustomerState());

  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';
  String get _ownerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  void initForEdit(Customer customer) {
    emit(state.copyWith(
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      comment: customer.comment,
      existingCustomer: customer,
      isEditing: true,
    ));
  }

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
      // Get the actual businessId from Firestore
      final businessId = await _businessIdProvider.getBusinessId();

      final customer = Customer(
        id: state.isEditing ? state.existingCustomer!.id : '',
        businessId: businessId,
        ownerId: _ownerId,
        name: state.name,
        phone: state.phone,
        email: state.email,
        address: state.address,
        comment: state.comment,
        createdAt: state.isEditing ? state.existingCustomer!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = state.isEditing
          ? await _customerRepository.updateCustomer(_email, customer)
          : await _customerRepository.createCustomer(_email, customer);

      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          error: failure.message,
        )),
        (created) => emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          createdCustomer: state.isEditing ? customer : (created as Customer),
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
