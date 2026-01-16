import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/pages/create_order_page.dart';
import '../../../orders/presentation/pages/orders_tab.dart';
import '../../../customers/presentation/pages/customers_tab.dart';
import '../../../products/presentation/pages/products_tab.dart';
import 'dashboard_tab.dart';

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

  void _onTabTapped(int index) {
    if (index == 2) {
      // Create Order Action
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateOrderPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
}

