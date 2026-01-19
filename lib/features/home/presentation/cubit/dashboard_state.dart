part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final String? error;
  
  // Stats
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final int completedOrders;
  
  // Lists
  final List<Order> urgentOrders;
  final List<Order> atRiskOrders;
  final List<Order> recentOrders;
  final List<TopProduct> topProducts;
  
  // Status Distribution
  final Map<String, int> statusCounts;
  
  // Business Info
  final String businessName;

  // Filter
  final DashboardFilter filter;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.totalCustomers = 0,
    this.completedOrders = 0,
    this.urgentOrders = const [],
    this.atRiskOrders = const [],
    this.recentOrders = const [],
    this.topProducts = const [],
    this.statusCounts = const {},
    this.businessName = 'OrderFlow', // Default
    this.filter = DashboardFilter.allTime,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    double? totalRevenue,
    int? totalOrders,
    int? totalCustomers,
    int? completedOrders,
    List<Order>? urgentOrders,
    List<Order>? atRiskOrders,
    List<Order>? recentOrders,
    List<TopProduct>? topProducts,
    Map<String, int>? statusCounts,
    String? businessName,
    DashboardFilter? filter,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      completedOrders: completedOrders ?? this.completedOrders,
      urgentOrders: urgentOrders ?? this.urgentOrders,
      atRiskOrders: atRiskOrders ?? this.atRiskOrders,
      recentOrders: recentOrders ?? this.recentOrders,
      topProducts: topProducts ?? this.topProducts,
      statusCounts: statusCounts ?? this.statusCounts,
      businessName: businessName ?? this.businessName,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        totalRevenue,
        totalOrders,
        totalCustomers,
        completedOrders,
        urgentOrders,
        atRiskOrders,
        recentOrders,
        topProducts,
        topProducts,
        statusCounts,
        businessName,
        filter,
      ];
}

class TopProduct extends Equatable {
  final String name;
  final int soldCount;
  final double percentage; // Relative to most sold

  const TopProduct({
    required this.name,
    required this.soldCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [name, soldCount, percentage];
}

enum DashboardFilter {
  allTime('All Time'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month');

  final String label;
  const DashboardFilter(this.label);
}
