import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';

import '../../../core/localization/i18n/strings.g.dart';
import '../../../core/ui_kit/colors.dart';
import '../../../core/ui_kit/typography.dart';

class TimeLinePicker extends StatefulWidget {
  const TimeLinePicker({super.key});

  @override
  State<TimeLinePicker> createState() => _TimeLinePickerState();
}

class _TimeLinePickerState extends State<TimeLinePicker> {
  bool dayIsSelected = true;
  EasyDatePickerController controller = EasyDatePickerController();
  DateTime selectedDate = DateTime.now();

  void _handleDateSelection(DateTime date) {
    selectedDate = date;
    controller.jumpToFocusDate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLinePicker.itemBuilder(
      controller: controller,
      headerOptions: HeaderOptions(
        headerType: HeaderType.viewOnly,
        headerBuilder: (context, date, onTap) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                AppIcons.icArrowLeft,
                Spacer(),
                Text(
                  DateFormat(
                    'd MMMM y',
                    LocaleSettings.currentLocale.languageCode,
                  ).format(date),
                  style: Typographies.regularH3,
                ),
                Spacer(),
                AppIcons.icArrowRight,
              ],
            ),
          );
        },
      ),
      focusedDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      onDateChange: (DateTime date) {
        _handleDateSelection(date);
      },
      itemExtent: 50,
      timelineOptions: TimelineOptions(height: 54),
      itemBuilder:
          (
            BuildContext context,
            DateTime date,
            bool isSelected,
            bool isDisabled,
            bool isToday,
            void Function() onTap,
          ) {
            Color? containerColor;
            Color dayTextColor;
            Color dateTextColor;

            if (isSelected) {
              containerColor = LightAppColors.primary;
              dayTextColor = LightAppColors.body; // or white
              dateTextColor = LightAppColors.body; // or white
            } else if (isToday) {
              containerColor = LightAppColors.primary.withOpacity(
                0.1,
              ); // subtle background for today
              dayTextColor = LightTextColor.primary;
              dateTextColor = LightTextColor.primary;
            } else {
              // ⚫ NORMAL DATE STYLE
              containerColor = null; // No background color
              dayTextColor = LightTextColor.secondary;
              dateTextColor = LightTextColor.primary;
            }

            return GestureDetector(
              onTap: () {
                _handleDateSelection(date);
              },
              child: Container(
                height: 54,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: containerColor,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 4,),
                    Text(
                      DateFormat(
                        'E',
                        LocaleSettings.currentLocale.languageCode,
                      ).format(date),
                      style: Typographies.regularBody2.copyWith(
                        color: dayTextColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      DateFormat(
                        'd',
                        LocaleSettings.currentLocale.languageCode,
                      ).format(date),
                      style: Typographies.regularBody.copyWith(
                        color: dateTextColor,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            );
          }, // Arabic locale
    );
  }
}
