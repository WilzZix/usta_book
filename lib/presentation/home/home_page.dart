import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/enums/enums.dart';
import 'package:usta_book/domain/extension/extensions.dart';

import '../../bloc/master/master_bloc.dart';
import '../../bloc/schedule/schedule_cubit.dart';
import '../../core/ui_kit/app_theme_extension.dart';
import '../../data/models/record_model.dart';
import '../add_new_record/add_new_record_page.dart';
import 'components/app_bar.dart';
import 'components/loading.dart';
import 'components/time_line_picker.dart';

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

  // void _handleDateSelection(DateTime date) {
  //   selectedDate = date;
  //   controller.jumpToFocusDate();
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().getTodayAppointments(date: DateTime.now());
  }

  RecordModel? _pickNextUpcoming(List<RecordModel> records) {
    final now = DateTime.now();
    RecordModel? best;
    int bestDelta = 1 << 62;
    for (final r in records) {
      final at = _parseAt(r.date, r.time);
      if (at == null) continue;
      final delta = at.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
      if (delta < 0) continue; // skip past
      if (delta < bestDelta) {
        bestDelta = delta;
        best = r;
      }
    }
    return best;
  }

  static DateTime? _parseAt(String date, String time) {
    final d = date.split('/');
    final t = time.split(':');
    if (d.length != 3 || t.length != 2) return null;
    final yy = int.tryParse(d[2]);
    final mm = int.tryParse(d[1]);
    final dd = int.tryParse(d[0]);
    final h = int.tryParse(t[0]);
    final mi = int.tryParse(t[1]);
    if ([yy, mm, dd, h, mi].any((v) => v == null)) return null;
    return DateTime(yy!, mm!, dd!, h!, mi!);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime? _parseDateOnly(String dateStr) {
    final p = dateStr.split('/');
    if (p.length != 3) return null;
    final dd = int.tryParse(p[0]);
    final mm = int.tryParse(p[1]);
    final yy = int.tryParse(p[2]);
    if (dd == null || mm == null || yy == null) return null;
    return DateTime(yy, mm, dd);
  }

  Widget _buildWeekView(
    BuildContext context,
    List<RecordModel> records,
    AppThemeExtension custom,
  ) {
    final groups = <String, List<RecordModel>>{};
    for (final r in records) {
      groups.putIfAbsent(r.date, () => []).add(r);
    }
    final dateKeys = groups.keys.toList()
      ..sort((a, b) {
        final da = _parseDateOnly(a);
        final db = _parseDateOnly(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    final locale = LocaleSettings.currentLocale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final dateKey in dateKeys) ...[
          Text(
            _formatDateHeader(dateKey, locale),
            style: Typographies.semiBoldH2,
          ),
          const SizedBox(height: 12),
          for (final r in groups[dateKey]!)
            _RecordCard(record: r, custom: custom),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  static String _formatDateHeader(String dateKey, String locale) {
    final d = _parseDateOnly(dateKey);
    if (d == null) return dateKey;
    return DateFormat('EEEE, d MMMM', locale).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: HomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: TimeLinePicker()),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  switch (state) {
                    case TodayAppointmentsLoading():
                      return HomeShimmerLoading();
                    case TodayAppointmentLoaded():
                      final isPast = state.isPast;
                      final isWeek = state.mode == ScheduleMode.week;
                      if (state.data.isEmpty) {
                        return Column(
                          children: [
                            AppIcons.icEmptyList,
                            Text(
                              isPast || isWeek
                                  ? tr.home.no_clients_on_day
                                  : tr.home.no_customers_added,
                              style: Typographies.regularBody2.copyWith(color: Color(0xFF6C757D)),
                            ),
                            if (!isPast && !isWeek) ...[
                              SizedBox(height: 12),
                              MainButton.primary(
                                title: tr.home.add_customer,
                                onTap: () {
                                  context.push(AddNewRecordPage.tag);
                                },
                              ),
                            ],
                          ],
                        );
                      }
                      if (isWeek) {
                        return _buildWeekView(context, state.data, custom);
                      }
                      final isToday = _isSameDay(state.selectedDate, DateTime.now());
                      final nearest =
                          isToday ? _pickNextUpcoming(state.data) : null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (nearest != null) ...[
                            Text(tr.home.theNearestClient, style: Typographies.semiBoldH2),
                            SizedBox(height: 12),
                            ClientStatusWidget(recordModel: nearest),
                            SizedBox(height: 24),
                          ],
                          Text(tr.home.todays_clients, style: Typographies.semiBoldH2),
                          SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            itemCount: state.data.length,
                            itemBuilder: (context, index) {
                              return _RecordCard(
                                record: state.data[index],
                                custom: custom,
                              );
                            },
                          ),
                          SizedBox(height: 12),
                        ],
                      );
                    case TodayAppointmentLoadError():
                      return Center(child: Text(state.msg));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientStatusWidget extends StatefulWidget {
  const ClientStatusWidget({super.key, required this.recordModel});

  final RecordModel recordModel;

  @override
  State<ClientStatusWidget> createState() => _ClientStatusWidgetState();
}

class _ClientStatusWidgetState extends State<ClientStatusWidget> {
  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return BlocListener<MasterBloc, MasterState>(
      listener: (context, state) {
        if (state is RecordUpdated) {
          context.read<ScheduleCubit>().getTodayAppointments(date: DateTime.now());
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: custom.body,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: StateColor.success),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIcons.icPerson,
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recordModel.clientName,
                      style: Typographies.regularBody.copyWith(color: TextColor.primary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.recordModel.time} • ${widget.recordModel.serviceType}',
                      style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.recordModel.price.strToUzbSum(), style: Typographies.regularH3.copyWith()),
                    SizedBox(height: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            switch (widget.recordModel.status) {
              null => SizedBox(),
              ClientStatus.waiting => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<MasterBloc>().add(
                        UpdateRecordEvent(record: widget.recordModel.copyWith(status: ClientStatus.rejected)),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: StateColor.error),
                        borderRadius: BorderRadius.circular(8),
                        color: StateColor.error.withValues(alpha: 0.1),
                      ),
                      child: Text(tr.home.client_did_not_come, style: Typographies.regularBody2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<MasterBloc>().add(
                        UpdateRecordEvent(record: widget.recordModel.copyWith(status: ClientStatus.inProgress)),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: StateColor.success),
                        borderRadius: BorderRadius.circular(8),
                        color: StateColor.success.withValues(alpha: 0.1),
                      ),
                      child: Text(tr.home.in_progress, style: Typographies.regularBody2),
                    ),
                  ),
                ],
              ),
              ClientStatus.inProgress => GestureDetector(
                onTap: () {
                  context.read<MasterBloc>().add(
                    UpdateRecordEvent(record: widget.recordModel.copyWith(status: ClientStatus.done)),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: StateColor.success),
                    borderRadius: BorderRadius.circular(8),
                    color: StateColor.success.withValues(alpha: 0.1),
                  ),
                  child: Text(tr.home.finished, style: Typographies.regularBody2),
                ),
              ),
              ClientStatus.done => SizedBox(),
              ClientStatus.rejected => GestureDetector(
                onTap: () {
                  //TODO
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: StateColor.error),
                    borderRadius: BorderRadius.circular(8),
                    color: StateColor.error.withValues(alpha: 0.1),
                  ),
                  child: Text(tr.home.finish_action, style: Typographies.regularBody2),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.custom});

  final RecordModel record;
  final AppThemeExtension custom;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcons.icPerson,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.clientName, style: Typographies.regularBody),
                const SizedBox(height: 8),
                Text(
                  '${record.time} • ${record.serviceType}',
                  style: Typographies.regularBody2.copyWith(
                    color: TextColor.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            record.price.strToUzbSum(),
            style: Typographies.regularH3,
          ),
        ],
      ),
    );
  }
}
