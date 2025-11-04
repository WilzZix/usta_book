import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../../core/ui_kit/components/app_icons.dart';

class SelectServiceTypeBottomSheet extends StatefulWidget {
  const SelectServiceTypeBottomSheet({super.key});

  static Future<String?> show({required BuildContext context}) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SelectServiceTypeBottomSheet();
      },
    );
  }

  @override
  State<SelectServiceTypeBottomSheet> createState() =>
      _SelectServiceTypeBottomSheetState();
}

class _SelectServiceTypeBottomSheetState
    extends State<SelectServiceTypeBottomSheet> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Xizmat turini tanlang', style: Typographies.semiBoldH2),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: AppIcons.icClose,
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: serviceTypes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      selectedIndex = index;
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIndex == index
                              ? LightAppColors.primary
                              : LightAppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(serviceTypes[index]),
                    ),
                  );
                },
              ),
            ),
            MainButton.primary(
              title: 'Tanlash',
              onTap: () {
                context.pop(serviceTypes[selectedIndex]);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

List<String> serviceTypes = [
  'Стрижка',
  'Окрашивание',
  'Педикюр',
  'Консультации',
  'Брови и ресницы',
  'Визаж',
  'Укладка',
  'Уход и восстановление',
  'Маникюр (классический)',
  'Покрытие',
  'Дизайн',
  'Наращивание/Коррекция',
  'Дополнительный уход',
];
