part of 'create_customer_cubit.dart';

class CreateCustomerState extends Equatable {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String comment;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;
  final Customer? createdCustomer;
  final Customer? existingCustomer;
  final bool isEditing;

  const CreateCustomerState({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.comment = '',
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
    this.createdCustomer,
    this.existingCustomer,
    this.isEditing = false,
  });

  bool get isValid => name.isNotEmpty && phone.isNotEmpty;

  CreateCustomerState copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? comment,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? isSuccess,
    Customer? createdCustomer,
    Customer? existingCustomer,
    bool? isEditing,
  }) {
    return CreateCustomerState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      createdCustomer: createdCustomer ?? this.createdCustomer,
      existingCustomer: existingCustomer ?? this.existingCustomer,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
        name,
        phone,
        email,
        address,
        comment,
        isSubmitting,
        error,
        isSuccess,
        createdCustomer,
      ];
}
