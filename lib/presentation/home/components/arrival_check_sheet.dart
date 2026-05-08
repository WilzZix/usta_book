import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/bloc/schedule/schedule_cubit.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/enums/enums.dart';

class ArrivalCheckSheet {
  static Future<void> show(BuildContext context, RecordModel record) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: custom.body,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _Body(record: record),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.record});

  final RecordModel record;

  void _update(BuildContext context, ClientStatus status) {
    context.read<MasterBloc>().add(
          UpdateRecordEvent(record: record.copyWith(status: status)),
        );
    context.read<ScheduleCubit>().getTodayAppointments(date: DateTime.now());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: custom.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(tr.home.arrival_check_title, style: Typographies.regularH3),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: custom.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: custom.body,
                    ),
                    child: AppIcons.icPerson,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.clientName, style: Typographies.regularBody),
                        const SizedBox(height: 2),
                        Text(
                          '${record.time} · ${record.serviceType}',
                          style: Typographies.regularOverlineLower,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _update(context, ClientStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StateColor.error,
                      side: BorderSide(color: StateColor.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(tr.home.client_did_not_come),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _update(context, ClientStatus.inProgress),
                    style: FilledButton.styleFrom(
                      backgroundColor: custom.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(tr.home.arrival_check_came),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr.home.arrival_check_dismiss),
            ),
          ],
        ),
      ),
    );
  }
}
