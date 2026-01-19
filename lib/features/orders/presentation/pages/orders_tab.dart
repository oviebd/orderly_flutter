import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/core/di/injection_container.dart';
import 'package:orderly/core/theme/app_colors.dart';
import 'package:orderly/core/theme/app_text_styles.dart';
import 'package:orderly/features/orders/presentation/cubit/order_cubit.dart';
import 'package:orderly/features/orders/presentation/widgets/order_card.dart';
import 'package:orderly/features/orders/presentation/pages/order_details_page.dart';
import 'package:orderly/core/navigation/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/core/presentation/widgets/tab_header.dart';
import 'package:orderly/core/presentation/widgets/order_flow_app_bar.dart';

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

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const OrderFlowAppBar(title: 'Orders'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final orderCubit = context.read<OrderCubit>();
          Navigator.pushNamed(
            context,
            AppRoutes.createOrder,
            arguments: email,
          ).then((_) {
             if (context.mounted) {
               orderCubit.fetchOrders(email);
             }
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {}); // Trigger rebuild to update local filter
                },
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
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.warning.withOpacity(0.2), 
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
                 listener: (context, state) {},
                 builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderLoaded) {
                     if (state.orders.isEmpty) {
                      return const Center(child: Text('No orders found'));
                    }
                    
                    final query = _searchController.text.toLowerCase();
                    
                    // Filter list locally for now (MVP)
                    final filteredOrders = state.orders.where((o) {
                      // Filter by status
                      final matchesStatus = _selectedFilter == 'All' || o.status.toLowerCase() == _selectedFilter.toLowerCase();
                      
                      // Filter by search query (name or phone)
                      final matchesSearch = query.isEmpty || 
                          (o.customerName?.toLowerCase().contains(query) ?? false) ||
                          (o.customerPhone?.toLowerCase().contains(query) ?? false);
                      
                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredOrders.isEmpty) {
                         return const Center(child: Text('No orders match filter'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Dismissible(
                          key: Key(order.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Order'),
                                content: const Text('Are you sure you want to delete this order?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            context.read<OrderCubit>().deleteOrder(order.id, email);
                          },
                          child: InkWell(
                            onTap: () {
                              final orderCubit = context.read<OrderCubit>();
                              Navigator.pushNamed(
                                context,
                                AppRoutes.orderDetails,
                                arguments: {
                                  'order': order,
                                  'orderCubit': orderCubit,
                                },
                              ).then((_) {
                                if (context.mounted) {
                                  orderCubit.fetchOrders(email);
                                }
                              });
                            },
                            child: OrderCard(
                              order: order,
                              onStatusChanged: (newStatus) {
                                context.read<OrderCubit>().updateStatus(order.id, newStatus, email);
                              },
                            ),
                          ),
                        );
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
