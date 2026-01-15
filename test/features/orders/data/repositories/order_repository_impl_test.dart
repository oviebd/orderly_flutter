import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orderly/core/error/failures.dart';
import 'package:orderly/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:orderly/features/orders/data/models/order_model.dart';
import 'package:orderly/features/orders/data/repositories/order_repository_impl.dart';

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

void main() {
  late OrderRepositoryImpl repository;
  late MockOrderRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(mockRemoteDataSource);
  });

  const tBusinessId = 'test_business_id';
  final tOrderModels = [
    OrderModel(
      id: '1',
      businessId: tBusinessId,
      ownerId: 'owner',
      customerId: 'cust1',
      status: 'pending',
      source: 'manual',
      address: 'addr',
      notes: '',
      orderDate: DateTime(2023),
      deliveryDate: DateTime(2023),
      deliveryCharge: 10,
      totalAmount: 100,
      products: const [],
    )
  ];

  group('getOrders', () {
    test('should return list of orders when call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getOrders(any()))
          .thenAnswer((_) async => tOrderModels);
      // act
      final result = await repository.getOrders(tBusinessId);
      // assert
      expect(result, Right(tOrderModels));
      verify(() => mockRemoteDataSource.getOrders(tBusinessId)).called(1);
    });

    test('should return ServerFailure when call to remote data source throws exception',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getOrders(any()))
          .thenThrow(Exception('Error'));
      // act
      final result = await repository.getOrders(tBusinessId);
      // assert
      expect(result, isA<Left<Failure, dynamic>>()); // Check it returns Left
      // Specific error check can vary depending on implementation details of ServerFailure string
    });
  });
}
