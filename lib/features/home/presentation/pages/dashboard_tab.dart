import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardCubit>()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading && state.totalOrders == 0) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.error != null && state.totalOrders == 0) {
            return _buildErrorState(context, state.error!);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildFilters(context, state),
                  const SizedBox(height: 24),
                  _buildSummaryCards(context, state),
                  const SizedBox(height: 24),
                  _buildAlerts(context, state),
                  const SizedBox(height: 24),
                  _buildAnalyticsSection(context, state),
                  const SizedBox(height: 24),
                  _buildRecentOrders(context, state),
                  const SizedBox(height: 24),
                  _buildNavigationLinks(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grid_view_rounded, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Text(
            'OrderFlow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
          onPressed: () => context.read<AuthCubit>().signOut(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome back! Here's your business.",
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF64748B).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            if (isMobile) const SizedBox(height: 16),
            if (!isMobile) const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to orders tab? 
              },
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              label: const Text('View All Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: isMobile ? const Size(double.infinity, 48) : null,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, DashboardState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...DashboardFilter.values.map((filter) {
            final isSelected = state.filter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<DashboardCubit>().loadDashboard(filter: filter);
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF14B8A6),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                ),
                elevation: 0,
                pressElevation: 0,
              ),
            );
          }),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Text(
                  'Pick a date range',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 48) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              label: 'REVENUE',
              value: '৳${NumberFormat('#,###').format(state.totalRevenue)}',
              icon: Icons.attach_money_rounded,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
              width: cardWidth > 150 ? cardWidth : (constraints.maxWidth - 16) / 2,
            ),
            _buildStatCard(
              label: 'ORDERS',
              value: state.totalOrders.toString(),
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF3B82F6),
              bgColor: const Color(0xFFEFF6FF),
              width: cardWidth > 150 ? cardWidth : (constraints.maxWidth - 16) / 2,
            ),
            _buildStatCard(
              label: 'CUSTOMERS',
              value: state.totalCustomers.toString(),
              icon: Icons.people_outline_rounded,
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF5F3FF),
              width: cardWidth > 150 ? cardWidth : (constraints.maxWidth - 16) / 2,
            ),
            _buildStatCard(
              label: 'COMPLETED',
              value: state.completedOrders.toString(),
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF14B8A6),
              bgColor: const Color(0xFFF0FDFA),
              width: cardWidth > 150 ? cardWidth : (constraints.maxWidth - 16) / 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wrapExpanded(
              isMobile,
              _buildAlertBox(
                title: 'Urgent - Due Today',
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFFF59E0B),
                orders: state.urgentOrders,
                emptyMessage: 'No urgent orders',
              ),
            ),
            if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
            _wrapExpanded(
              isMobile,
              _buildAlertBox(
                title: 'At Risk - Overdue',
                icon: Icons.warning_rounded,
                iconColor: const Color(0xFFEF4444),
                orders: state.atRiskOrders,
                emptyMessage: 'No overdue orders',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _wrapExpanded(bool skip, Widget child) {
    if (skip) return SizedBox(width: double.infinity, child: child);
    return Expanded(child: child);
  }

  Widget _buildAlertBox({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Order> orders,
    required String emptyMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  orders.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (orders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  emptyMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ...orders.take(3).map((order) => _buildAlertItem(order)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customerName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Due: ${DateFormat('MMM dd').format(order.deliveryDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Donut
            _wrapExpanded(
              isMobile,
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(100, 100),
                                painter: DonutChartPainter(
                                  counts: state.statusCounts,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.totalOrders.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _buildChartLegend('Pending', state.statusCounts['pending'] ?? 0, const Color(0xFFF59E0B)),
                              _buildChartLegend('Completed', state.statusCounts['completed'] ?? 0, const Color(0xFF10B981)),
                              _buildChartLegend('Processing', state.statusCounts['processing'] ?? 0, const Color(0xFF3B82F6)),
                              _buildChartLegend('Cancelled', state.statusCounts['cancelled'] ?? 0, const Color(0xFFEF4444)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
            // Top Selling Products
            _wrapExpanded(
              isMobile,
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 18, color: Color(0xFF14B8A6)),
                        SizedBox(width: 10),
                        Text(
                          'Top Selling Products',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (state.topProducts.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No sales data yet', style: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                      )
                    else
                      ...state.topProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        return _buildTopProductRow(index + 1, product);
                      }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartLegend(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductRow(int rank, TopProduct product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              rank.toString(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    Text(
                      '${product.soldCount} sold',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: product.percentage,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF3B82F6)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.recentOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No orders yet', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            )
          else
            ...state.recentOrders.take(5).map((order) => _buildRecentOrderRow(order)),
        ],
      ),
    );
  }

  Widget _buildRecentOrderRow(Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              (order.customerName?.isNotEmpty ?? false) ? order.customerName![0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                Text(
                  order.products.map((p) => p.name).join(', '),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${order.totalAmount.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text(
                DateFormat('MMM dd, h:mm a').format(order.orderDate),
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(width: 20),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF10B981);
        break;
      case 'pending':
        color = const Color(0xFFF59E0B);
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        break;
      case 'processing':
        color = const Color(0xFF3B82F6);
        break;
      default:
        color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toLowerCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNavigationLinks(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            _wrapExpanded(isMobile, _buildNavCard(context, 'Orders', Icons.list_alt_rounded, const Color(0xFFECFDF5))),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
            _wrapExpanded(isMobile, _buildNavCard(context, 'Products', Icons.inventory_2_outlined, const Color(0xFFEFF6FF))),
            if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
            _wrapExpanded(isMobile, _buildNavCard(context, 'Customers', Icons.people_outline_rounded, const Color(0xFFF5F3FF))),
          ],
        );
      },
    );
  }

  Widget _buildNavCard(BuildContext context, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: Colors.blueGrey[800]),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<DashboardCubit>().loadDashboard(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, int> counts;

  DonutChartPainter({required this.counts});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = counts.values.fold(0, (sum, val) => sum + val).toDouble();
    if (total == 0) {
      final paint = Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;
      canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 6, paint);
      return;
    }

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final strokeWidth = 12.0;

    double startAngle = -math.pi / 2;

    final statusColors = {
      'pending': const Color(0xFFF59E0B),
      'completed': const Color(0xFF10B981),
      'processing': const Color(0xFF3B82F6),
      'cancelled': const Color(0xFFEF4444),
    };

    counts.forEach((status, count) {
      if (count > 0) {
        final sweepAngle = (count / total) * 2 * math.pi;
        final paint = Paint()
          ..color = statusColors[status] ?? Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
        startAngle += sweepAngle;
      }
    });

    // Draw background if not full
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
