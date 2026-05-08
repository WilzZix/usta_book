import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/schedule/schedule_cubit.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../../core/ui_kit/app_theme_extension.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return AppBar(
      title: Text(tr.home.table, style: Typographies.boldH1),
      backgroundColor: custom.body,
      centerTitle: false,
      actions: [
        BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            ScheduleMode mode = ScheduleMode.day;
            DateTime selectedDate = DateTime.now();
            if (state is TodayAppointmentLoaded) {
              mode = state.mode;
              selectedDate = state.selectedDate;
            }
            final dayActive = mode == ScheduleMode.day;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  _ToggleButton(
                    label: tr.home.day,
                    active: dayActive,
                    onTap: () {
                      if (!dayActive) {
                        context.read<ScheduleCubit>().loadDay(selectedDate);
                      }
                    },
                  ),
                  _ToggleButton(
                    label: tr.home.week,
                    active: !dayActive,
                    onTap: () {
                      if (dayActive) {
                        context.read<ScheduleCubit>().loadWeek(selectedDate);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 88,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: Typographies.regularBody2.copyWith(
              color: active ? AppColors.secondaryBg : TextColor.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
