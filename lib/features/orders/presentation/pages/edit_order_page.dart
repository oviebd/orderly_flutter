import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orderly/core/di/injection_container.dart';
import 'package:orderly/core/theme/app_colors.dart';
import 'package:orderly/features/products/domain/entities/product.dart';
import 'package:orderly/features/orders/domain/entities/order.dart';
import 'package:orderly/features/orders/presentation/cubit/create_order_cubit.dart';

class EditOrderPage extends StatelessWidget {
  final Order order;
  const EditOrderPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateOrderCubit>()..initForEdit(order),
      child: const _EditOrderView(),
    );
  }
}

class _EditOrderView extends StatefulWidget {
  const _EditOrderView();

  @override
  State<_EditOrderView> createState() => _EditOrderViewState();
}

class _EditOrderViewState extends State<_EditOrderView> {
  late TextEditingController _phoneController;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _deliveryChargeController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CreateOrderCubit>();
    _phoneController = TextEditingController(text: cubit.state.selectedCustomer?.phone);
    _nameController = TextEditingController(text: cubit.state.selectedCustomer?.name);
    _addressController = TextEditingController(text: cubit.state.selectedCustomer?.address);
    _notesController = TextEditingController(text: cubit.state.notes);
    _deliveryChargeController = TextEditingController(text: cubit.state.deliveryCharge.toInt().toString());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _deliveryChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateOrderCubit, CreateOrderState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order updated successfully!'), backgroundColor: AppColors.success),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
          context.read<CreateOrderCubit>().clearError();
        }

        // Update controllers when customer data is finally loaded
        if (state.selectedCustomer != null) {
          if (_phoneController.text.isEmpty && state.selectedCustomer!.phone.isNotEmpty) {
            _phoneController.text = state.selectedCustomer!.phone;
          }
          if (_nameController.text.isEmpty && state.selectedCustomer!.name.isNotEmpty) {
            _nameController.text = state.selectedCustomer!.name;
          }
           if (_addressController.text.isEmpty && state.selectedCustomer!.address.isNotEmpty) {
            _addressController.text = state.selectedCustomer!.address;
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Edit Order', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCustomerCard(context, state),
                const SizedBox(height: 16),
                _buildSourceCard(context, state),
                const SizedBox(height: 16),
                _buildStatusCard(context, state),
                const SizedBox(height: 16),
                _buildProductsCard(context, state),
                const SizedBox(height: 16),
                _buildPricingCard(context, state),
                const SizedBox(height: 16),
                _buildNotesCard(context, state),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildCustomerCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          // Name and Phone are visible but read-only as per requirements
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Delivery Address',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => context.read<CreateOrderCubit>().updateCustomerAddress(v),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: OrderSource.values.map((s) {
              final isSelected = state.orderSource == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(s.displayName),
                    selected: isSelected,
                    onSelected: (_) => context.read<CreateOrderCubit>().setOrderSource(s),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, CreateOrderState state) {
    if (!state.isEditing) return const SizedBox.shrink();

    final statuses = ['Pending', 'Processing', 'Completed', 'Cancelled'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statuses.map((status) {
              final isSelected = state.status.toLowerCase() == status.toLowerCase();
              Color chipColor;
              switch (status.toLowerCase()) {
                case 'completed': chipColor = AppColors.success; break;
                case 'cancelled': chipColor = AppColors.error; break;
                case 'processing': chipColor = AppColors.primary; break;
                default: chipColor = AppColors.warning;
              }

              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<CreateOrderCubit>().setOrderStatus(status);
                  }
                },
                selectedColor: chipColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? chipColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? chipColor : AppColors.border),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.read<CreateOrderCubit>().addEmptyProduct(),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add Item'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No items added yet', style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
              ),
            ),
          ...state.products.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: item.name,
                          decoration: const InputDecoration(
                            hintText: 'Item Name',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          onChanged: (v) => context.read<CreateOrderCubit>().updateProduct(idx, item.copyWith(name: v)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => context.read<CreateOrderCubit>().removeProduct(idx),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item.price == 0 ? '' : item.price.toInt().toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '৳',
                            labelText: 'Price',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => context.read<CreateOrderCubit>().updateProduct(idx, item.copyWith(price: double.tryParse(v) ?? 0)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () => context.read<CreateOrderCubit>().decrementProductQuantity(idx),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => context.read<CreateOrderCubit>().incrementProductQuantity(idx),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          TextField(
            controller: _deliveryChargeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Delivery Charge', border: OutlineInputBorder()),
            onChanged: (v) => context.read<CreateOrderCubit>().setDeliveryCharge(double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('৳${state.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
        onChanged: (v) => context.read<CreateOrderCubit>().setNotes(v),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: ElevatedButton(
        onPressed: state.isSubmitting || !state.isValid ? null : () => context.read<CreateOrderCubit>().submitOrder(),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
        child: state.isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('Update Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
