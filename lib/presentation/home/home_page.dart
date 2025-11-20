import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../bloc/schedule/schedule_cubit.dart';
import 'components/app_bar.dart';
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

  void _handleDateSelection(DateTime date) {
    selectedDate = date;
    controller.jumpToFocusDate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().getTodayAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimeLinePicker(),
              SizedBox(height: 24),
              Text(tr.home.theNearestClient, style: Typographies.semiBoldH2),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LightAppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIcons.icPerson,
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barotov Nodirbek',
                          style: Typographies.regularBody.copyWith(
                            color: LightTextColor.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '09:00 • Soch kesish',
                          style: Typographies.regularBody2.copyWith(
                            color: LightTextColor.secondary,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '30 daqiqadan so\'ng',
                          style: Typographies.regularBody2.copyWith(
                            color: LightTextColor.secondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('12\$', style: Typographies.regularH3.copyWith()),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  switch (state) {
                    case TodayAppointmentsLoading():
                      return CircularProgressIndicator();
                    case TodayAppointmentLoaded():
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.data.length,
                        itemBuilder: (context, index) {
                          return Text(state.data[index].clientName);
                        },
                      );
                    case TodayAppointmentLoadError():
                      return Center(child: Text(state.msg));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
