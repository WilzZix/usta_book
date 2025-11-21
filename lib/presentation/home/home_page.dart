import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../bloc/schedule/schedule_cubit.dart';
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

  void _handleDateSelection(DateTime date) {
    selectedDate = date;
    controller.jumpToFocusDate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().getTodayAppointments(date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
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
                      if (state.data.isEmpty) {
                        return Column(
                          children: [
                            AppIcons.icEmptyList,
                            SizedBox(height: 12),
                            Text(
                              'Hali mijoz qushilmagan',
                              style: Typographies.semiBoldH2,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Yangi mijoz qo‘shib, boshqarishni boshlang.',
                              style: Typographies.regularBody2.copyWith(
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            SizedBox(height: 12),
                            MainButton.primary(
                              title: 'Mijoz qushish',
                              onTap: () {
                                context.go(AddNewRecordPage.tag);
                              },
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.home.theNearestClient,
                            style: Typographies.semiBoldH2,
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
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
                                      state.data[0].clientName,
                                      style: Typographies.regularBody.copyWith(
                                        color: LightTextColor.primary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${state.data[0].time} • ${state.data[0].serviceType}',
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
                                      state.data[0].price,
                                      style: Typographies.regularH3.copyWith(),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Bugungi uchrashuvlar',
                            style: Typographies.semiBoldH2,
                          ),
                          SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            itemCount: state.data.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: LightAppColors.border,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppIcons.icPerson,
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.data[index].clientName,
                                          style: Typographies.regularBody
                                              .copyWith(
                                                color: LightTextColor.primary,
                                              ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${state.data[index].time} • ${state.data[index].serviceType}',
                                          style: Typographies.regularBody2
                                              .copyWith(
                                                color: LightTextColor.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          state.data[index].price,
                                          style: Typographies.regularH3
                                              .copyWith(),
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
