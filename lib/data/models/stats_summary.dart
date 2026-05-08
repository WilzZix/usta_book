import 'package:cloud_firestore/cloud_firestore.dart';

class StatsSummary {
  final String month;
  final int monthlyOrders;
  final num monthlyRevenue;
  final num avgBill;
  final int totalClients;
  final int returningClients;
  final int retentionRate;
  final TopService? topService;
  final List<TopClient> topClients;

  const StatsSummary({
    required this.month,
    required this.monthlyOrders,
    required this.monthlyRevenue,
    required this.avgBill,
    required this.totalClients,
    required this.returningClients,
    required this.retentionRate,
    required this.topService,
    required this.topClients,
  });

  factory StatsSummary.empty() => const StatsSummary(
        month: '',
        monthlyOrders: 0,
        monthlyRevenue: 0,
        avgBill: 0,
        totalClients: 0,
        returningClients: 0,
        retentionRate: 0,
        topService: null,
        topClients: [],
      );

  factory StatsSummary.fromMap(Map<String, dynamic> data) {
    return StatsSummary(
      month: data['month'] as String? ?? '',
      monthlyOrders: (data['monthlyOrders'] as num?)?.toInt() ?? 0,
      monthlyRevenue: (data['monthlyRevenue'] as num?) ?? 0,
      avgBill: (data['avgBill'] as num?) ?? 0,
      totalClients: (data['totalClients'] as num?)?.toInt() ?? 0,
      returningClients: (data['returningClients'] as num?)?.toInt() ?? 0,
      retentionRate: (data['retentionRate'] as num?)?.toInt() ?? 0,
      topService: data['topService'] is Map<String, dynamic>
          ? TopService.fromMap(data['topService'] as Map<String, dynamic>)
          : null,
      topClients: (data['topClients'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TopClient.fromMap)
          .toList(),
    );
  }
}

class TopService {
  final String name;
  final int count;

  const TopService({required this.name, required this.count});

  factory TopService.fromMap(Map<String, dynamic> data) {
    return TopService(
      name: data['name'] as String? ?? '',
      count: (data['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopClient {
  final String name;
  final String phone;
  final int visits;
  final DateTime? lastVisit;
  final num totalSpent;

  const TopClient({
    required this.name,
    required this.phone,
    required this.visits,
    required this.lastVisit,
    required this.totalSpent,
  });

  factory TopClient.fromMap(Map<String, dynamic> data) {
    final ts = data['lastVisit'];
    return TopClient(
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      visits: (data['visits'] as num?)?.toInt() ?? 0,
      lastVisit: ts is Timestamp ? ts.toDate() : null,
      totalSpent: (data['totalSpent'] as num?) ?? 0,
    );
  }
}
