import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/enums/enums.dart';
import 'package:usta_book/domain/extension/extensions.dart';

import '../../bloc/master/master_bloc.dart';
import '../../bloc/schedule/schedule_cubit.dart';
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
              child: Text('Bugungi statistika', style: Typographies.semiBoldH2),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LightAppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('3', style: Typographies.regularH3),
                        SizedBox(height: 8),
                        Text('Zakazlar', style: Typographies.regularBody2),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LightAppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('120 000', style: Typographies.regularH3),
                        SizedBox(height: 8),
                        Text('Daromad', style: Typographies.regularBody2),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LightAppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('3 soat', style: Typographies.regularH3),
                        SizedBox(height: 8),
                        Text('Vaqt', style: Typographies.regularBody2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
                          ClientStatusWidget(recordModel: state.data[0]),
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
                                          state.data[index].price.strToUzbSum(),
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

class ClientStatusWidget extends StatefulWidget {
  const ClientStatusWidget({super.key, required this.recordModel});

  final RecordModel recordModel;

  @override
  State<ClientStatusWidget> createState() => _ClientStatusWidgetState();
}

class _ClientStatusWidgetState extends State<ClientStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    style: Typographies.regularBody.copyWith(
                      color: LightTextColor.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.recordModel.time} • ${widget.recordModel.serviceType}',
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
                    widget.recordModel.price.strToUzbSum(),
                    style: Typographies.regularH3.copyWith(),
                  ),
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
                    //TODO
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: StateColor.error),
                      borderRadius: BorderRadius.circular(8),
                      color: StateColor.error.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      'Klient kelmadi',
                      style: Typographies.regularBody2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<MasterBloc>().add(
                      UpdateRecordEvent(
                        record: widget.recordModel.copyWith(
                          status: ClientStatus.inProgress,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: StateColor.success),
                      borderRadius: BorderRadius.circular(8),
                      color: StateColor.success.withValues(alpha: 0.1),
                    ),
                    child: Text('Jarayonda', style: Typographies.regularBody2),
                  ),
                ),
              ],
            ),
            ClientStatus.inProgress => GestureDetector(
              onTap: () {
                //TODO
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: StateColor.success),
                  borderRadius: BorderRadius.circular(8),
                  color: StateColor.success.withValues(alpha: 0.1),
                ),
                child: Text('Tugadi', style: Typographies.regularBody2),
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
                child: Text('Tugatish', style: Typographies.regularBody2),
              ),
            ),
          },
        ],
      ),
    );
  }
}
