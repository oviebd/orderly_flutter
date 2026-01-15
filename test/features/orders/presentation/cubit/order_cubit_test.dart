import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orderly/core/error/failures.dart';
import 'package:orderly/features/orders/domain/entities/order.dart';
import 'package:orderly/features/orders/domain/repositories/order_repository.dart';
import 'package:orderly/features/orders/presentation/cubit/order_cubit.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late OrderCubit orderCubit;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    orderCubit = OrderCubit(mockOrderRepository);
  });

  tearDown(() {
    orderCubit.close();
  });

  const tBusinessId = 'test_business_id';
  final tOrders = [
    Order(
      id: '1',
      businessId: tBusinessId,
      ownerId: 'owner',
      customerId: 'cust1',
      status: 'pending',
      source: 'manual',
      address: 'addr',
      notes: '',
      orderDate: DateTime.now(),
      deliveryDate: DateTime.now(),
      deliveryCharge: 10,
      totalAmount: 100,
      products: const [],
    )
  ];

  group('OrderCubit', () {
    test('initial state should be OrderInitial', () {
      expect(orderCubit.state, equals(OrderInitial()));
    });

    blocTest<OrderCubit, OrderState>(
      'emits [OrderLoading, OrderLoaded] when fetchOrders is successful',
      build: () {
        when(() => mockOrderRepository.getOrders(any()))
            .thenAnswer((_) async => Right(tOrders));
        return orderCubit;
      },
      act: (cubit) => cubit.fetchOrders(tBusinessId),
      expect: () => [
        OrderLoading(),
        OrderLoaded(tOrders),
      ],
      verify: (_) {
        verify(() => mockOrderRepository.getOrders(tBusinessId)).called(1);
      },
    );

    blocTest<OrderCubit, OrderState>(
      'emits [OrderLoading, OrderError] when fetchOrders fails',
      build: () {
        when(() => mockOrderRepository.getOrders(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Error')));
        return orderCubit;
      },
      act: (cubit) => cubit.fetchOrders(tBusinessId),
      expect: () => [
        OrderLoading(),
        const OrderError('Error'),
      ],
    );
  });
}
