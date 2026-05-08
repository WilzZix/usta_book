import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/bloc/stats/stats_cubit.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/stats_summary.dart';
import 'package:usta_book/presentation/statistics/components/client_details_sheet.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  static const String tag = '/statistics';

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatsCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: custom.body,
      appBar: AppBar(
        backgroundColor: custom.body,
        elevation: 0,
        title: Text(tr.statistics.title, style: Typographies.boldH1),
        centerTitle: false,
      ),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatsError) {
            return Center(child: Text(state.msg));
          }
          final summary = (state as StatsLoaded).summary;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BigStatCard(
                        icon: Icons.calendar_today_outlined,
                        value: summary.monthlyOrders.toString(),
                        label: tr.statistics.monthly_orders,
                        custom: custom,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BigStatCard(
                        icon: Icons.account_balance_wallet_outlined,
                        value: _formatMoney(summary.monthlyRevenue, tr.statistics.currency_suffix),
                        label: tr.statistics.monthly_revenue,
                        custom: custom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SmallStatCard(
                        value: '${summary.retentionRate}%',
                        label: tr.statistics.retention,
                        custom: custom,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallStatCard(
                        value: _formatMoney(summary.avgBill, tr.statistics.currency_suffix),
                        label: tr.statistics.avg_bill,
                        custom: custom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(tr.statistics.top_clients, style: Typographies.regularH3),
                const SizedBox(height: 12),
                if (summary.topClients.isEmpty)
                  _EmptyHint(text: tr.statistics.no_data, custom: custom)
                else
                  ...summary.topClients.take(5).map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TopClientItem(
                            client: c,
                            custom: custom,
                            visitsLabel: tr.statistics.visits_suffix,
                            onTap: () => ClientDetailsSheet.show(context, c),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Text(tr.statistics.popular_service, style: Typographies.regularH3),
                const SizedBox(height: 12),
                _PopularServiceCard(
                  service: summary.topService,
                  custom: custom,
                  emptyText: tr.statistics.no_data,
                  timesLabel: tr.statistics.times_suffix,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatMoney(num value, String suffix) {
  final f = NumberFormat('#,##0');
  return '${f.format(value)} $suffix';
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.custom,
  });

  final IconData icon;
  final String value;
  final String label;
  final AppThemeExtension custom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: custom.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: custom.primary),
              const SizedBox(width: 6),
              Text(value, style: Typographies.semiBoldH2),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: Typographies.regularBody2),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.value,
    required this.label,
    required this.custom,
  });

  final String value;
  final String label;
  final AppThemeExtension custom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: custom.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: Typographies.regularH3),
          const SizedBox(height: 2),
          Text(
            label,
            style: Typographies.regularOverlineLower,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopClientItem extends StatelessWidget {
  const _TopClientItem({
    required this.client,
    required this.custom,
    required this.visitsLabel,
    required this.onTap,
  });

  final TopClient client;
  final AppThemeExtension custom;
  final String visitsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: custom.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: custom.body,
              ),
              child: AppIcons.icPerson,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name.isEmpty ? '—' : client.name,
                    style: Typographies.regularBody,
                  ),
                  const SizedBox(height: 2),
                  if (client.phone.isNotEmpty)
                    Text(
                      client.phone,
                      style: Typographies.regularOverlineLower,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '${client.visits} $visitsLabel',
                    style: Typographies.regularOverlineLower
                        .copyWith(color: custom.primary),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: custom.primary),
          ],
        ),
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  const _PopularServiceCard({
    required this.service,
    required this.custom,
    required this.emptyText,
    required this.timesLabel,
  });

  final TopService? service;
  final AppThemeExtension custom;
  final String emptyText;
  final String timesLabel;

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return _EmptyHint(text: emptyText, custom: custom);
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: custom.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(service!.name, style: Typographies.regularBody),
              ),
              Text(
                '${service!.count} $timesLabel',
                style: Typographies.regularOverlineLower,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 6,
              backgroundColor: custom.body,
              valueColor: AlwaysStoppedAnimation(custom.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text, required this.custom});

  final String text;
  final AppThemeExtension custom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: custom.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Typographies.regularBody2,
      ),
    );
  }
}
