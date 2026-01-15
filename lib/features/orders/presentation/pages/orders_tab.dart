import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/order_cubit.dart'; // Ensure correct import
import '../widgets/order_card.dart';

import 'package:firebase_auth/firebase_auth.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Processing', 'Completed', 'Cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return BlocProvider(
      create: (context) => sl<OrderCubit>()..fetchOrders(email),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text('Orders', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search orders by customer, phone...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = filter;
                          // TODO: Implement filtering logic in Cubit or locally
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.warning.withOpacity(0.2), // Light yellow for selected, purely visual example
                      // Ideal selected color logic depends on filter type (Green for completed etc)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border), 
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),

            // Order List
            Expanded(
              child: BlocConsumer<OrderCubit, OrderState>(
                 listener: (context, state) {
                  if (state is OrderError) {
                    // Show snackbar or visual cue?
                    // But we handle it in builder too.
                  }
                 },
                 builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderLoaded) {
                     if (state.orders.isEmpty) {
                      return const Center(child: Text('No orders found'));
                    }
                    
                    // Filter list locally for now (MVP)
                    final filteredOrders = _selectedFilter == 'All' 
                        ? state.orders 
                        : state.orders.where((o) => o.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                    if (filteredOrders.isEmpty) {
                         return const Center(child: Text('No orders match filter'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(order: order);
                      },
                    );
                  } else if (state is OrderError) {
                     // Check if it's the index error
                     if (state.message.contains('failed-precondition')) {
                         return Padding(
                           padding: const EdgeInsets.all(24.0),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
                               const SizedBox(height: 16),
                               const Text(
                                 "Database Index Missing",
                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                               ),
                               const SizedBox(height: 8),
                               const Text(
                                 "Firebase requires an index for this query. Please check your debug console for a link to create it automatically.",
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: AppColors.textSecondary),
                               ),
                               const SizedBox(height: 16),
                               SelectableText(
                                 state.message, // Let user copy the error/link if possible
                                 style: const TextStyle(fontSize: 10, color: Colors.grey),
                               ),
                             ],
                           ),
                         );
                     }
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('Pull to refresh'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
