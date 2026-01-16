import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;

  const OrderCard({super.key, required this.order, this.onTap, this.onStatusChanged});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'processing':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.customerName ?? 'Unknown Customer'} (${order.source})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(order.orderDate)} ➔ ${_formatDate(order.deliveryDate)}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context, order.status, statusColor),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getProductSummary(order.products),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '৳${order.totalAmount.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, Color color) {
    final statuses = ['Pending', 'Processing', 'Completed', 'Cancelled'];

    return PopupMenuButton<String>(
      onSelected: (newStatus) {
        if (onStatusChanged != null) {
          onStatusChanged!(newStatus);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
      itemBuilder: (context) => statuses.map((s) {
        return PopupMenuItem<String>(
          value: s,
          child: Text(s),
        );
      }).toList(),
    );
  }

  String _getProductSummary(List<dynamic> products) {
    if (products.isEmpty) return 'No items';
    // Assuming products list has items with 'name' and 'quantity'
    // Logic to stringify: "Macbook Pro x1, iPad x2"
    return products.map((p) => '${p.name} x${p.quantity}').join(', ');
  }
  
  String _formatDate(DateTime date) {
    // Basic formatting
    return DateFormat('MMM d').format(date);
    // Ideally compare with today and return 'Today', 'Yesterday' etc if desired.
  }
}
