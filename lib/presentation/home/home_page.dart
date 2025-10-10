import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../core/ui_kit/components/app_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String tag = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.home.table, style: Typographies.boldH1),
        centerTitle: false,
        actions: [
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dayIsSelected = true;
                    });
                  },
                  child: Container(
                    height: 32,
                    width: 88,
                    decoration: BoxDecoration(
                      color: dayIsSelected ? LightAppColors.primary : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        tr.home.day,
                        style: Typographies.regularBody2.copyWith(
                          color: dayIsSelected
                              ? LightAppColors.secondaryBg
                              : LightTextColor.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dayIsSelected = false;
                    });
                  },
                  child: Container(
                    height: 32,
                    width: 88,
                    decoration: BoxDecoration(
                      color: dayIsSelected
                          ? LightAppColors.secondaryBg
                          : LightAppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        tr.home.week,
                        style: Typographies.regularBody2.copyWith(
                          color: dayIsSelected
                              ? LightTextColor.secondary
                              : LightAppColors.secondaryBg,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EasyDateTimeLinePicker.itemBuilder(
              controller: controller,
              headerOptions: HeaderOptions(
                headerType: HeaderType.viewOnly,
                headerBuilder: (context, date, onTap) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
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
                      // 🟢 SELECTED DATE STYLE
                      containerColor = LightAppColors.primary;
                      dayTextColor = LightAppColors.body; // or white
                      dateTextColor = LightAppColors.body; // or white
                    } else if (isToday) {
                      // 🟡 TODAY'S DATE STYLE (but not selected)
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
                          ],
                        ),
                      ),
                    );
                  }, // Arabic locale
            ),
          ],
        ),
      ),
    );
  }
}
