import 'package:flutter/material.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  // Change 2: Override preferredSize getter
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool dayIsSelected = true;

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                    color: dayIsSelected ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      tr.home.day,
                      style: Typographies.regularBody2.copyWith(
                        color: dayIsSelected
                            ? AppColors.secondaryBg
                            : TextColor.secondary,
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
                        ? AppColors.secondaryBg
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      tr.home.week,
                      style: Typographies.regularBody2.copyWith(
                        color: dayIsSelected
                            ? TextColor.secondary
                            : AppColors.secondaryBg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
