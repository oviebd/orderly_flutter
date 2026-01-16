import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/core/di/injection_container.dart';
import 'package:orderly/core/theme/app_colors.dart';
import 'package:orderly/features/orders/presentation/pages/orders_tab.dart';
import 'package:orderly/features/customers/presentation/pages/customers_tab.dart';
import 'package:orderly/features/products/presentation/pages/products_tab.dart';
import 'package:orderly/core/navigation/app_routes.dart';
import 'package:orderly/features/home/presentation/pages/dashboard_tab.dart';
import 'package:orderly/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:orderly/features/orders/presentation/cubit/order_cubit.dart';
import 'package:orderly/features/products/presentation/cubit/products_cubit.dart';
import 'package:orderly/features/customers/presentation/cubit/customers_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(),
    const SizedBox(), // Placeholder for center button action
    const ProductsTab(),
    const CustomersTab(),
  ];

  void _onTabTapped(BuildContext context, int index) async {
    if (index == 2) {
      // Create Order Action
      final result = await Navigator.pushNamed(context, AppRoutes.createOrder);
      if (result == true && mounted) {
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        context.read<DashboardCubit>().loadDashboard();
        context.read<OrderCubit>().fetchOrders(email);
        // Also refresh customers in case a new customer was created during order
        context.read<CustomersCubit>().loadCustomers();
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<DashboardCubit>()..loadDashboard()),
        BlocProvider(create: (context) => sl<OrderCubit>()..fetchOrders(email)),
        BlocProvider(create: (context) => sl<ProductsCubit>()..loadProducts()),
        BlocProvider(create: (context) => sl<CustomersCubit>()..loadCustomers()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => _onTabTapped(context, index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle, size: 40, color: AppColors.primary),
                  label: '',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
              ],
            ),
          );
        }
      ),
    );
  }
}

