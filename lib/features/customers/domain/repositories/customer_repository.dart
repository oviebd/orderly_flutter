import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  /// Get all customers for a business
  Future<Either<Failure, List<Customer>>> getCustomers(String businessId);

  /// Search customers by phone number or name
  Future<Either<Failure, List<Customer>>> searchCustomers(
    String businessId,
    String query,
  );

  /// Get a specific customer by ID
  Future<Either<Failure, Customer?>> getCustomerById(
    String businessId,
    String customerId,
  );

  /// Create a new customer
  Future<Either<Failure, Customer>> createCustomer(
    String businessId,
    Customer customer,
  );

  /// Update an existing customer
  Future<Either<Failure, void>> updateCustomer(
    String businessId,
    Customer customer,
  );

  /// Delete a customer by ID
  Future<Either<Failure, void>> deleteCustomer(String businessId, String customerId);
}
