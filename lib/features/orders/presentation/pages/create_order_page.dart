import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../cubit/create_order_cubit.dart';

class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateOrderCubit>(),
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();

  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryChargeController = TextEditingController(text: '0');

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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Order created successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<CreateOrderCubit>().clearError();
        }

        // Sync controllers with state when customer is selected
        if (state.selectedCustomer != null) {
          if (_nameController.text != state.selectedCustomer!.name) {
            _nameController.text = state.selectedCustomer!.name;
          }
          if (_addressController.text != state.selectedCustomer!.address) {
            _addressController.text = state.selectedCustomer!.address;
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSection(context, state),
                        const SizedBox(height: 20),
                        _buildOrderSourceSection(context, state),
                        const SizedBox(height: 20),
                        _buildProductsSection(context, state),
                        const SizedBox(height: 20),
                        _buildPricingSummary(context, state),
                        const SizedBox(height: 20),
                        _buildScheduleSection(context, state),
                        const SizedBox(height: 20),
                        _buildNotesSection(context, state),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Column(
        children: [
          Text(
            'New Order',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCustomerSection(BuildContext context, CreateOrderState state) {
    final isExisting = state.selectedCustomer?.isExisting ?? false;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Customer Details',
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 20),

          // Phone field
          _buildInputField(
            label: 'Phone Number',
            isRequired: true,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(
                hint: 'Enter phone number...',
                prefixIcon: Icons.phone_outlined,
              ),
              onChanged: (value) {
                context.read<CreateOrderCubit>().updateCustomerPhone(value);
              },
            ),
          ),

          // Customer suggestions
          if (state.customerSearchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.customerSearchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final customer = state.customerSearchResults[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(customer.phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () {
                      context.read<CreateOrderCubit>().selectExistingCustomer(customer);
                      _phoneController.text = customer.phone;
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Name and Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Name',
                  isRequired: true,
                  child: TextField(
                    controller: _nameController,
                    readOnly: isExisting,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration(
                      hint: 'Customer name',
                      filled: isExisting,
                    ),
                    onChanged: (value) {
                      context.read<CreateOrderCubit>().updateCustomerName(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Address',
                  child: TextField(
                    controller: _addressController,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration(
                      hint: 'Delivery address',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    onChanged: (value) {
                      context.read<CreateOrderCubit>().updateCustomerAddress(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSourceSection(BuildContext context, CreateOrderState state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Order Source',
            icon: Icons.campaign_outlined,
            iconColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 20),
          Row(
            children: OrderSource.values.map((source) {
              final isSelected = state.orderSource == source;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.read<CreateOrderCubit>().setOrderSource(source),
                  child: Container(
                    margin: EdgeInsets.only(right: source != OrderSource.values.last ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getSourceIcon(source),
                          size: 22,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          source.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(OrderSource source) {
    switch (source) {
      case OrderSource.whatsapp:
        return Icons.chat_bubble_outline;
      case OrderSource.messenger:
        return Icons.messenger_outline;
      case OrderSource.phone:
        return Icons.phone_outlined;
    }
  }

  Widget _buildProductsSection(BuildContext context, CreateOrderState state) {
    return _buildCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Products',
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFF10B981),
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 18, color: Color(0xFF10B981)),
              label: const Text(
                'Add',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
              ),
              onPressed: () => context.read<CreateOrderCubit>().addEmptyProduct(),
            ),
          ),
          const SizedBox(height: 16),

          if (state.products.isEmpty)
            _buildEmptyProductsState()
          else
            ...state.products.asMap().entries.map((entry) {
              return _buildProductItem(context, state, entry.key, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products added',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "Add" to add your first product',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    CreateOrderState state,
    int index,
    OrderProductItem product,
  ) {
    return Container(
      margin: EdgeInsets.only(top: index > 0 ? 16 : 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with delete button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () => context.read<CreateOrderCubit>().removeProduct(index),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product Name
          _ProductSearchField(
            initialValue: product.name,
            onSearch: (query) => context.read<CreateOrderCubit>().searchProducts(query),
            onChanged: (value) {
              context.read<CreateOrderCubit>().updateProduct(
                    index,
                    product.copyWith(name: value),
                  );
            },
            suggestions: state.productSearchResults,
            onSuggestionSelected: (p) {
              context.read<CreateOrderCubit>().selectProductFromSearch(index, p);
            },
          ),
          const SizedBox(height: 12),

          // Price and Quantity row
          Row(
            children: [
              // Price
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      controller: TextEditingController(text: product.price > 0 ? product.price.toString() : ''),
                      onChanged: (value) {
                        final price = double.tryParse(value) ?? 0;
                        context.read<CreateOrderCubit>().updateProduct(index, product.copyWith(price: price));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Qty',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQtyButton(
                          icon: Icons.remove,
                          onPressed: () => context.read<CreateOrderCubit>().decrementProductQuantity(index),
                        ),
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: Text(
                            '${product.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        _buildQtyButton(
                          icon: Icons.add,
                          onPressed: () => context.read<CreateOrderCubit>().incrementProductQuantity(index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details field
          TextField(
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Additional details (color, size, etc.)',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            controller: TextEditingController(text: product.details),
            onChanged: (value) {
              context.read<CreateOrderCubit>().updateProduct(index, product.copyWith(details: value));
            },
          ),

          // Item Total
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item Total',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF10B981)),
                ),
                Text(
                  '\$${product.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildPricingSummary(BuildContext context, CreateOrderState state) {
    return _buildCard(
      child: Column(
        children: [
          // Delivery Charge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Text(
                    'Delivery Charge',
                    style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _deliveryChargeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (value) {
                    final charge = double.tryParse(value) ?? 0;
                    context.read<CreateOrderCubit>().setDeliveryCharge(charge);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '\$${state.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, CreateOrderState state) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Schedule',
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 20),

          // Order Date Row
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Order Date',
                  isRequired: true,
                  value: dateFormat.format(state.orderDate),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.orderDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null && context.mounted) {
                      context.read<CreateOrderCubit>().setOrderDate(date);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  label: 'Time',
                  value: state.orderTime != null
                      ? '${state.orderTime!.hour.toString().padLeft(2, '0')}:${state.orderTime!.minute.toString().padLeft(2, '0')}'
                      : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: state.orderTime ?? TimeOfDay.now(),
                    );
                    if (context.mounted) {
                      context.read<CreateOrderCubit>().setOrderTime(time);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delivery Date Row
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Delivery Date',
                  isRequired: true,
                  value: dateFormat.format(state.deliveryDate),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.deliveryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null && context.mounted) {
                      context.read<CreateOrderCubit>().setDeliveryDate(date);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  label: 'Time',
                  value: state.deliveryTime != null
                      ? '${state.deliveryTime!.hour.toString().padLeft(2, '0')}:${state.deliveryTime!.minute.toString().padLeft(2, '0')}'
                      : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: state.deliveryTime ?? TimeOfDay.now(),
                    );
                    if (context.mounted) {
                      context.read<CreateOrderCubit>().setDeliveryTime(time);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? '--:--',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, CreateOrderState state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Notes',
            icon: Icons.note_alt_outlined,
            iconColor: const Color(0xFF64748B),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add any special instructions or notes...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              context.read<CreateOrderCubit>().setNotes(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CreateOrderState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.isSubmitting || !state.isValid
                  ? null
                  : () => context.read<CreateOrderCubit>().submitOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Create Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    bool filled = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)) : null,
      filled: true,
      fillColor: filled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

/// Product search field with autocomplete
class _ProductSearchField extends StatefulWidget {
  final String initialValue;
  final Function(String) onSearch;
  final Function(String) onChanged;
  final List<Product> suggestions;
  final Function(Product) onSuggestionSelected;

  const _ProductSearchField({
    required this.initialValue,
    required this.onSearch,
    required this.onChanged,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  State<_ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<_ProductSearchField> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && widget.suggestions.isNotEmpty;
      });
    });
  }

  @override
  void didUpdateWidget(_ProductSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = widget.suggestions.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Product Name',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search or enter product name...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            widget.onChanged(value);
            widget.onSearch(value);
          },
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final product = widget.suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981))),
                  trailing: product.code.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.code,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        )
                      : null,
                  onTap: () {
                    _controller.text = product.name;
                    widget.onSuggestionSelected(product);
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
