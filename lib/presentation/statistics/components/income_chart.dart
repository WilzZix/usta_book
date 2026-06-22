import 'package:flutter/material.dart';
import 'package:usta_book/bloc/statistics/statistics_cubit.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class IncomeChart extends StatelessWidget {
  const IncomeChart({super.key, required this.entries, required this.period});

  final List<BarChartEntry> entries;
  final StatsPeriod period;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;

    final localizedEntries = entries.map((e) {
      final label = _localizeLabel(e.label, period, tr);
      return BarChartEntry(label: label, value: e.value);
    }).toList();

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
          Text(tr.statistics.income_chart, style: Typographies.semiBoldH2),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: _BarChart(entries: localizedEntries, color: custom.primary),
          ),
        ],
      ),
    );
  }

  String _localizeLabel(String label, StatsPeriod period, Translations tr) {
    if (period == StatsPeriod.month) return label;
    const map = {
      'Mon': 'mon',
      'Tue': 'tue',
      'Wed': 'wed',
      'Thu': 'thu',
      'Fri': 'fri',
      'Sat': 'sat',
      'Sun': 'sun',
    };
    final key = map[label];
    if (key == null) return label;
    switch (key) {
      case 'mon':
        return tr.statistics.mon;
      case 'tue':
        return tr.statistics.tue;
      case 'wed':
        return tr.statistics.wed;
      case 'thu':
        return tr.statistics.thu;
      case 'fri':
        return tr.statistics.fri;
      case 'sat':
        return tr.statistics.sat;
      case 'sun':
        return tr.statistics.sun;
      default:
        return label;
    }
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.entries, required this.color});

  final List<BarChartEntry> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxVal =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: entries.map((entry) {
        final fraction = maxVal == 0 ? 0.0 : entry.value / maxVal;
        return _Bar(
          label: entry.label,
          fraction: fraction,
          color: color,
          isEmpty: entry.value == 0,
        );
      }).toList(),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.fraction,
    required this.color,
    required this.isEmpty,
  });

  final String label;
  final double fraction;
  final Color color;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    const maxHeight = 100.0;
    const minHeight = 4.0;
    final barHeight =
        isEmpty ? minHeight : (maxHeight * fraction).clamp(minHeight, maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          width: 24,
          height: barHeight,
          decoration: BoxDecoration(
            color: isEmpty ? color.withValues(alpha: 0.2) : color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Typographies.regularOverlineLower
              .copyWith(color: TextColor.secondary),
        ),
      ],
    );
  }
}
