import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/statistics/statistics_cubit.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/extension/extensions.dart';
import 'package:usta_book/presentation/statistics/components/income_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  static const String tag = '/statistics';

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatsPeriod _period = StatsPeriod.today;

  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadStats(_period);
  }

  void _selectPeriod(StatsPeriod period) {
    if (_period == period) return;
    setState(() => _period = period);
    context.read<StatisticsCubit>().loadStats(period);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.statistics.title, style: Typographies.boldH1),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PeriodSelector(
              selected: _period,
              onSelect: _selectPeriod,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<StatisticsCubit, StatisticsState>(
              builder: (context, state) {
                return switch (state) {
                  StatisticsLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  StatisticsError(:final msg) => Center(
                      child: Text(msg, style: Typographies.regularBody),
                    ),
                  StatisticsLoaded() => _LoadedBody(state: state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Period Selector ───────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelect});

  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final theme = Theme.of(context);

    final periods = [
      (StatsPeriod.today, tr.statistics.today),
      (StatsPeriod.week, tr.statistics.week),
      (StatsPeriod.month, tr.statistics.month),
    ];

    return Container(
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: periods.map((item) {
          final (period, label) = item;
          final isSelected = selected == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? custom.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Typographies.regularBody2.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.bottomNavigationBarTheme.unselectedItemColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Loaded Body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final StatisticsLoaded state;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    if (state.records.isEmpty) {
      return Center(
        child: Text(
          tr.statistics.no_appointments,
          style: Typographies.regularBody.copyWith(color: TextColor.secondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    final incomeText = state.totalIncome == 0
        ? '0 so\'m'
        : state.totalIncome.toString().strToUzbSum();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: state.totalOrders.toString(),
                label: tr.statistics.orders,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: incomeText,
                label: tr.statistics.income,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: state.doneCount.toString(),
                label: tr.statistics.done,
                color: StateColor.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: state.rejectedCount.toString(),
                label: tr.statistics.rejected,
                color: StateColor.error,
              ),
            ),
          ],
        ),

        // Income chart (week / month only)
        if (state.period != StatsPeriod.today) ...[
          const SizedBox(height: 16),
          IncomeChart(entries: state.chartData, period: state.period),
        ],

        // Top services
        if (state.serviceBreakdown.isNotEmpty) ...[
          const SizedBox(height: 16),
          _TopServices(breakdown: state.serviceBreakdown),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Typographies.semiBoldH2.copyWith(color: TextColor.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                Typographies.regularBody2.copyWith(color: TextColor.secondary),
          ),
        ],
      ),
    );
  }
}

// ─── Top Services ──────────────────────────────────────────────────────────────

class _TopServices extends StatelessWidget {
  const _TopServices({required this.breakdown});

  final Map<String, int> breakdown;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final total = breakdown.values.fold(0, (s, v) => s + v);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.statistics.top_services, style: Typographies.semiBoldH2),
          const SizedBox(height: 12),
          ...breakdown.entries.map((entry) {
            final fraction = total == 0 ? 0.0 : entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ServiceRow(
                name: entry.key,
                count: entry.value,
                fraction: fraction,
                color: custom.primary,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.name,
    required this.count,
    required this.fraction,
    required this.color,
  });

  final String name;
  final int count;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: Typographies.regularBody2
                    .copyWith(color: TextColor.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              count.toString(),
              style: Typographies.regularBody2
                  .copyWith(color: TextColor.secondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
