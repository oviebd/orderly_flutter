import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  /// Search products by name or code
  Future<Either<Failure, List<Product>>> searchProducts(
    String businessId,
    String query,
  );

  /// Get a specific product by ID
  Future<Either<Failure, Product?>> getProductById(
    String businessId,
    String productId,
  );

  /// Create a new product
  Future<Either<Failure, Product>> createProduct(
    String businessId,
    Product product,
  );
}
