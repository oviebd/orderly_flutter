import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';

import '../../features/orders/presentation/cubit/order_cubit.dart';
import '../../features/orders/presentation/cubit/create_order_cubit.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/data/datasources/order_remote_data_source.dart';
import '../../features/home/presentation/cubit/dashboard_cubit.dart';

import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/presentation/cubit/create_customer_cubit.dart';
import '../../features/customers/presentation/cubit/customers_cubit.dart';

import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/presentation/cubit/create_product_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';

import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Core
  
  // Auth Feature
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  
  // Home Feature (Dashboard)
  sl.registerFactory(() => DashboardCubit(
    orderRepository: sl(),
    customerRepository: sl(),
    productRepository: sl(),
  ));
  
  // Customer Feature
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(sl()));
  sl.registerLazySingleton<CustomerRemoteDataSource>(() => CustomerRemoteDataSourceImpl(sl()));
  sl.registerFactory(() => CreateCustomerCubit(customerRepository: sl()));
  sl.registerFactory(() => CustomersCubit(customerRepository: sl()));
  
  // Product Feature
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(sl()));
  sl.registerFactory(() => CreateProductCubit(productRepository: sl()));
  sl.registerFactory(() => ProductsCubit(productRepository: sl()));
  
  // Order Feature
  sl.registerFactory(() => OrderCubit(sl()));
  sl.registerFactory(() => CreateOrderCubit(
    customerRepository: sl(),
    productRepository: sl(),
    orderRepository: sl(),
  ));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(sl()));

  // Profile Feature
  sl.registerFactory(() => ProfileCubit(profileRepository: sl(), auth: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));
}

