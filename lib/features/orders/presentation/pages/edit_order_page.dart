import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/order.dart';
import '../cubit/create_order_cubit.dart';

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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            onChanged: (v) => context.read<CreateOrderCubit>().updateCustomerName(v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
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

  Widget _buildProductsCard(BuildContext context, CreateOrderState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () => context.read<CreateOrderCubit>().addEmptyProduct(),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          ...state.products.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return ListTile(
              title: Text(item.name.isEmpty ? 'Untitled Item' : item.name),
              subtitle: Text('${item.quantity} x ৳${item.price.toInt()}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => context.read<CreateOrderCubit>().removeProduct(idx),
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
