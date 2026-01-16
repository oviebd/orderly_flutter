import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orderly/features/orders/domain/entities/order.dart';
import 'package:orderly/core/theme/app_colors.dart';
import 'package:orderly/features/orders/presentation/cubit/order_cubit.dart';
import 'package:orderly/core/navigation/app_routes.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.pushNamed(
                context,
                AppRoutes.editOrder,
                arguments: order,
              );
              if (updated == true && mounted) {
                // Return true to parent to trigger reload
                Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 24),
            _buildCustomerInfo(),
            const SizedBox(height: 24),
            _buildProductsList(),
            const SizedBox(height: 24),
            _buildPriceSummary(),
            const SizedBox(height: 24),
            _buildOrderMeta(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final status = order.status.toLowerCase();
    Color color;
    IconData icon;
    
    switch (status) {
      case 'completed':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        color = const Color(0xFFF59E0B);
        icon = Icons.access_time_filled_rounded;
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        break;
      case 'processing':
        color = const Color(0xFF3B82F6);
        icon = Icons.sync_rounded;
        break;
      default:
        color = const Color(0xFF64748B);
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Spacer(),
          _buildSourceBadge(),
        ],
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            order.source.toLowerCase() == 'whatsapp' ? Icons.message : Icons.language,
            size: 12,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            order.source,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          Text(order.customerName ?? 'Walk-in Customer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(order.customerPhone!, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(child: Text(order.address, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          ...order.products.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      if (item.code.isNotEmpty) Text(item.code, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Text('৳${(item.price * item.quantity).toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final subtotal = order.products.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '৳${subtotal.toInt()}', Colors.white70),
          const SizedBox(height: 12),
          _buildPriceRow('Delivery Charge', '৳${order.deliveryCharge.toInt()}', Colors.white70),
          const Divider(height: 32, color: Colors.white24),
          _buildPriceRow('Total', '৳${order.totalAmount.toInt()}', Colors.white, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500)),
        Text(value, style: TextStyle(color: color, fontSize: isTotal ? 22 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700)),
      ],
    );
  }

  Widget _buildOrderMeta() {
    return Column(
      children: [
        _buildMetaItem(Icons.calendar_today_outlined, 'Order Date', DateFormat('MMM dd, yyyy - hh:mm a').format(order.orderDate)),
        const SizedBox(height: 12),
        _buildMetaItem(Icons.local_shipping_outlined, 'Delivery Date', DateFormat('MMM dd, yyyy').format(order.deliveryDate)),
        if (order.notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildMetaItem(Icons.notes_rounded, 'Notes', order.notes),
        ],
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    if (order.status.toLowerCase() == 'completed' || order.status.toLowerCase() == 'cancelled') return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(context, 'completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mark Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => _updateStatus(context, 'cancelled'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.close, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, String newStatus) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    // Use email for Firestore document path
    context.read<OrderCubit>().updateStatus(order.id, newStatus, email);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to $newStatus')),
    );
  }
}
