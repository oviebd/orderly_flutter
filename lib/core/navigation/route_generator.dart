import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/features/auth/presentation/pages/login_page.dart';
import 'package:orderly/features/home/presentation/pages/main_screen.dart';
import 'package:orderly/features/orders/domain/entities/order.dart';
import 'package:orderly/features/orders/presentation/cubit/order_cubit.dart';
import 'package:orderly/features/orders/presentation/pages/create_order_page.dart';
import 'package:orderly/features/orders/presentation/pages/edit_order_page.dart';
import 'package:orderly/features/orders/presentation/pages/order_details_page.dart';
import 'package:orderly/features/products/domain/entities/product.dart';
import 'package:orderly/features/products/presentation/pages/create_product_page.dart';
import 'package:orderly/features/products/presentation/pages/edit_product_page.dart';
import 'package:orderly/features/products/presentation/pages/product_details_page.dart';
import 'package:orderly/features/customers/domain/entities/customer.dart';
import 'package:orderly/features/customers/presentation/pages/create_customer_page.dart';
import 'package:orderly/features/customers/presentation/pages/edit_customer_page.dart';
import 'package:orderly/features/customers/presentation/pages/customer_details_page.dart';
import 'package:orderly/features/profile/presentation/pages/profile_page.dart';
import 'package:orderly/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:orderly/features/profile/domain/entities/business_profile.dart';
import 'package:orderly/core/navigation/app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.initial:
        // This is handled in main.dart based on auth state, but we can define it here too
        return MaterialPageRoute(builder: (_) => const MainScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      // Orders
      case AppRoutes.createOrder:
        return MaterialPageRoute<bool>(builder: (_) => const CreateOrderPage());
      
      case AppRoutes.orderDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: args['orderCubit'] as OrderCubit,
              child: OrderDetailsPage(order: args['order'] as Order),
            ),
          );
        }
        return _errorRoute();

      case AppRoutes.editOrder:
        if (args is Order) {
          return MaterialPageRoute<bool>(builder: (_) => EditOrderPage(order: args));
        }
        return _errorRoute();

      // Products
      case AppRoutes.createProduct:
        return MaterialPageRoute<Product>(builder: (_) => const CreateProductPage());

      case AppRoutes.productDetails:
        if (args is Product) {
          return MaterialPageRoute(builder: (_) => ProductDetailsPage(product: args));
        }
        return _errorRoute();

      case AppRoutes.editProduct:
        if (args is Product) {
          return MaterialPageRoute<Product>(builder: (_) => EditProductPage(product: args));
        }
        return _errorRoute();

      // Customers
      case AppRoutes.createCustomer:
        return MaterialPageRoute<Customer>(builder: (_) => const CreateCustomerPage());

      case AppRoutes.customerDetails:
        if (args is Customer) {
          return MaterialPageRoute(builder: (_) => CustomerDetailsPage(customer: args));
        }
        return _errorRoute();

      case AppRoutes.editCustomer:
        if (args is Customer) {
          return MaterialPageRoute<Customer>(builder: (_) => EditCustomerPage(customer: args));
        }
        return _errorRoute();

      // Profile
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case AppRoutes.editProfile:
        if (args is BusinessProfile) {
          return MaterialPageRoute<BusinessProfile>(builder: (_) => EditProfilePage(profile: args));
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      );
    });
  }
}
