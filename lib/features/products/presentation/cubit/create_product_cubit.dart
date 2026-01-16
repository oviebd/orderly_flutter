import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/core/services/business_id_provider.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

part 'create_product_state.dart';

class CreateProductCubit extends Cubit<CreateProductState> {
  final ProductRepository _productRepository;
  final BusinessIdProvider _businessIdProvider = BusinessIdProvider();

  CreateProductCubit({
    required ProductRepository productRepository,
  })  : _productRepository = productRepository,
        super(const CreateProductState());

  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';
  String get _ownerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  void initForEdit(Product product) {
    emit(state.copyWith(
      name: product.name,
      code: product.code,
      price: product.price,
      details: product.details,
      existingProduct: product,
      isEditing: true,
    ));
  }

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  void setCode(String code) {
    emit(state.copyWith(code: code));
  }

  void setPrice(double price) {
    emit(state.copyWith(price: price));
  }

  void setDetails(String details) {
    emit(state.copyWith(details: details));
  }

  Future<void> submitProduct() async {
    if (!state.isValid) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      // Get the actual businessId from Firestore
      final businessId = await _businessIdProvider.getBusinessId();

      final product = Product(
        id: state.isEditing ? state.existingProduct!.id : '',
        businessId: businessId,
        ownerId: _ownerId,
        name: state.name,
        code: state.code,
        details: state.details,
        price: state.price,
        createdAt: state.isEditing ? state.existingProduct!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = state.isEditing
          ? await _productRepository.updateProduct(_email, product)
          : await _productRepository.createProduct(_email, product);

      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          error: failure.message,
        )),
        (created) => emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          createdProduct: state.isEditing ? product : (created as Product),
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

