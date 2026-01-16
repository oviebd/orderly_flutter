import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _productRepository;

  ProductsCubit({
    required ProductRepository productRepository,
  })  : _productRepository = productRepository,
        super(const ProductsState());

  String get _businessId => FirebaseAuth.instance.currentUser?.email ?? '';

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _productRepository.getProducts(_businessId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (products) => emit(state.copyWith(
        isLoading: false,
        products: products,
      )),
    );
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      loadProducts();
      return;
    }

    emit(state.copyWith(isLoading: true, searchQuery: query));

    final result = await _productRepository.searchProducts(_businessId, query);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (products) => emit(state.copyWith(
        isLoading: false,
        products: products,
      )),
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', clearSearch: true));
    loadProducts();
  }

  void addProductToList(Product product) {
    final updated = [product, ...state.products];
    emit(state.copyWith(products: updated));
  }
}
