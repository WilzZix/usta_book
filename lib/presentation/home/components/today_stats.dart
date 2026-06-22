import 'package:flutter/material.dart';

import '../../../core/localization/i18n/strings.g.dart';
import '../../../core/ui_kit/app_theme_extension.dart';
import '../../../core/ui_kit/colors.dart';
import '../../../core/ui_kit/typography.dart';
import '../../../data/models/record_model.dart';
import '../../../domain/extension/extensions.dart';

class TodayStats extends StatelessWidget {
  const TodayStats({super.key, required this.records});

  final List<RecordModel> records;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final orders = records.length;
    final income = records.fold<int>(0, (sum, r) => sum + (int.tryParse(r.price) ?? 0));
    final hours = orders;
    final incomeText = income == 0 ? '0 so\'m' : income.toString().strToUzbSum();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.home.todays_statistics, style: Typographies.semiBoldH2),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(value: orders.toString(), label: tr.home.stat_orders)),
            SizedBox(width: 8),
            Expanded(child: _StatCard(value: incomeText, label: tr.home.stat_income)),
            SizedBox(width: 8),
            Expanded(child: _StatCard(value: '$hours ${tr.home.hours_short}', label: tr.home.stat_time)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: Typographies.regularH3.copyWith(color: TextColor.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
          ),
        ],
      ),
    );
  }
}
