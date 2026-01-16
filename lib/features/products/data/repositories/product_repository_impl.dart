import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts(String businessId) async {
    try {
      final products = await _remoteDataSource.getProducts(businessId);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(
    String businessId,
    String query,
  ) async {
    try {
      final products = await _remoteDataSource.searchProducts(
        businessId,
        query,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(
    String businessId,
    String productId,
  ) async {
    try {
      final product = await _remoteDataSource.getProductById(
        businessId,
        productId,
      );
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(
    String businessId,
    Product product,
  ) async {
    try {
      final model = ProductModel.fromEntity(product);
      final created = await _remoteDataSource.createProduct(
        businessId,
        model,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> updateProduct(
    String businessId,
    Product product,
  ) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _remoteDataSource.updateProduct(businessId, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
