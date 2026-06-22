part of 'statistics_cubit.dart';

enum StatsPeriod { today, week, month }

@immutable
sealed class StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<RecordModel> records;
  final StatsPeriod period;

  StatisticsLoaded({required this.records, required this.period});

  int get totalOrders => records.length;

  int get totalIncome =>
      records.fold<int>(0, (sum, r) => sum + (int.tryParse(r.price) ?? 0));

  int get doneCount =>
      records.where((r) => r.status == ClientStatus.done).length;

  int get rejectedCount =>
      records.where((r) => r.status == ClientStatus.rejected).length;

  Map<String, int> get serviceBreakdown {
    final map = <String, int>{};
    for (final r in records) {
      if (r.serviceType.isNotEmpty) {
        map[r.serviceType] = (map[r.serviceType] ?? 0) + 1;
      }
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  /// Returns income grouped for the chart.
  /// Week  → 7 entries (Mon–Sun of current week), index 0 = Monday.
  /// Month → weeks in current month (up to 5).
  List<BarChartEntry> get chartData {
    final now = DateTime.now();
    if (period == StatsPeriod.today) return [];

    if (period == StatsPeriod.week) {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return List.generate(7, (i) {
        final day = DateTime(monday.year, monday.month, monday.day + i);
        final income = records
            .where((r) {
              final d = _parseDate(r.date);
              return d != null &&
                  d.year == day.year &&
                  d.month == day.month &&
                  d.day == day.day;
            })
            .fold<int>(0, (s, r) => s + (int.tryParse(r.price) ?? 0));
        return BarChartEntry(label: _weekdayLabel(i), value: income.toDouble());
      });
    }

    // month → group by ISO week number within the month
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final weeks = <int, int>{};
    for (var d = firstDay;
        !d.isAfter(lastDay);
        d = d.add(const Duration(days: 1))) {
      final weekNum = ((d.day - 1) ~/ 7) + 1;
      weeks[weekNum] = 0;
    }
    for (final r in records) {
      final d = _parseDate(r.date);
      if (d == null) continue;
      final weekNum = ((d.day - 1) ~/ 7) + 1;
      if (weeks.containsKey(weekNum)) {
        weeks[weekNum] = weeks[weekNum]! + (int.tryParse(r.price) ?? 0);
      }
    }
    return weeks.entries
        .map((e) =>
            BarChartEntry(label: 'W${e.key}', value: e.value.toDouble()))
        .toList();
  }

  static DateTime? _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  static String _weekdayLabel(int index) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[index];
  }
}

class StatisticsError extends StatisticsState {
  final String msg;

  StatisticsError({required this.msg});
}

class BarChartEntry {
  final String label;
  final double value;

  const BarChartEntry({required this.label, required this.value});
}
