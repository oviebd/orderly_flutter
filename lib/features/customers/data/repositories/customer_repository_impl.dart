import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(String businessId) async {
    try {
      final customers = await _remoteDataSource.getCustomers(businessId);
      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers(
    String businessId,
    String query,
  ) async {
    try {
      final customers = await _remoteDataSource.searchCustomers(
        businessId,
        query,
      );
      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer?>> getCustomerById(
    String businessId,
    String customerId,
  ) async {
    try {
      final customer = await _remoteDataSource.getCustomerById(
        businessId,
        customerId,
      );
      return Right(customer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer(
    String businessId,
    Customer customer,
  ) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      final created = await _remoteDataSource.createCustomer(
        businessId,
        model,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> updateCustomer(
    String businessId,
    Customer customer,
  ) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await _remoteDataSource.updateCustomer(businessId, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
