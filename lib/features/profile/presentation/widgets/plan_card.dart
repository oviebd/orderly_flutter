import 'package:flutter/material.dart';
import 'package:orderly/core/theme/app_colors.dart';
import '../../domain/entities/plan.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPlanColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plan.name,
                    style: TextStyle(
                      color: _getPlanColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '৳${plan.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '/ month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFeatureRow(Icons.check_circle_outline, '${plan.capabilities.maxOrderNumber} Orders', true),
            _buildFeatureRow(Icons.check_circle_outline, '${plan.capabilities.maxCustomerNumber} Customers', true),
            _buildFeatureRow(Icons.check_circle_outline, '${plan.capabilities.maxProductNumber} Products', true),
            _buildFeatureRow(
              plan.capabilities.hasExportImportOption ? Icons.check_circle_outline : Icons.cancel_outlined,
              'Import/Export Data',
              plan.capabilities.hasExportImportOption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isEnabled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isEnabled ? const Color(0xFF475569) : const Color(0xFFEF4444).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor() {
    switch (plan.id.toLowerCase()) {
      case 'elite':
        return const Color(0xFF8B5CF6); // Purple
      case 'gold':
        return const Color(0xFFF59E0B); // Amber
      case 'silver':
        return const Color(0xFF64748B); // Slate/Silver
      case 'lite':
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }
}
