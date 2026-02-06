import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class WorkingHoursCard extends StatefulWidget {
  const WorkingHoursCard({
    super.key,
    required this.title,
    required this.from,
    required this.to,
    required this.fromTapped,
    required this.toTapped,
    this.value,
    this.onChanged,
  });

  final String title;
  final String from;
  final String to;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Function() fromTapped;
  final Function() toTapped;

  @override
  State<WorkingHoursCard> createState() => _WorkingHoursCardState();
}

class _WorkingHoursCardState extends State<WorkingHoursCard> {
  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onChanged != null) {
                widget.onChanged!(!(widget.value ?? false));
              }
            },
            child: widget.value ?? true
                ? AppIcons.icSelectedRectangleSelected
                : Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: custom.secondary),
                    ),
                  ),
          ),
          SizedBox(width: 8),
          Text(widget.title, style: Typographies.regularBody),
          Spacer(),
          GestureDetector(
            onTap: widget.fromTapped,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: custom.body,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(widget.from, style: Typographies.regularOverlineLower),
                  SizedBox(width: 8),
                  AppIcons.icWatch,
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            height: 1,
            width: 10,
            decoration: BoxDecoration(shape: BoxShape.rectangle, color: AppColors.border),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: widget.toTapped,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: custom.body,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(widget.to, style: Typographies.regularOverlineLower),
                  SizedBox(width: 8),
                  AppIcons.icWatch,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayTranslator {
  static const Map<String, Map<String, String>> translations = {
    'ru': {
      'mon': 'Понедельник',
      'tue': 'Вторник',
      'wed': 'Среда',
      'thurs': 'Четверг',
      'fri': 'Пятница',
      'sat': 'Суббота',
      'sun': 'Воскресенье',
    },
    'uz': {
      'mon': 'Dushanba',
      'tue': 'Seshanba',
      'wed': 'Chorshanba',
      'thurs': 'Payshanba',
      'fri': 'Juma',
      'sat': 'Shanba',
      'sun': 'Yakshanba',
    },
  };

  static String translate(String day, String lang) {
    return translations[lang]?[day.toLowerCase()] ?? day;
  }
}
