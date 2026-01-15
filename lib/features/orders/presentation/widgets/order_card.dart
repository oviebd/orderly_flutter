import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'processing':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final currencyFormat = NumberFormat.simpleCurrency(name: 'BDT'); // Assuming BDT based on screenshot (৳)
    // Or uses symbol if provided. Screenshot shows '৳8,000'.
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Color Strip
              Container(
                width: 4,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Name, Icon, Source, Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.customerName ?? order.customerId, 
                                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(${order.source})",
                                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // Gap between name section and price
                          Text(
                            '৳${order.totalAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Products summary
                      Text(
                        _getProductSummary(order.products),
                         style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Footer: Date and Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(order.orderDate),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          _buildStatusBadge(order.status, statusColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toLowerCase(),
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
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
