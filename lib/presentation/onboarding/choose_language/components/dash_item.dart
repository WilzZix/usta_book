import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';

class DashItem extends StatelessWidget {
  const DashItem({super.key, required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: isDone ? LightAppColors.primary : LightAppColors.border,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
