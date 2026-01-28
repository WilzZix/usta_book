import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class LanguageItem extends StatelessWidget {
  const LanguageItem({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: AppColors.primary)
              : Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 16),
            Text(title, style: Typographies.regularBody),
            Spacer(),
            if (selected) AppIcons.icCheckMark,
          ],
        ),
      ),
    );
  }
}
