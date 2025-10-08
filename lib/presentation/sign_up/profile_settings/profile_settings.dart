import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/sources/firebase/firebase_service.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  static const String tag = '/profile-settings';

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  bool isMondayChecked = true;
  bool isTuesdayChecked = true;
  bool isWednesdayChecked = true;
  bool isThursdayChecked = true;
  bool isFridayChecked = true;
  bool isSaturdayChecked = true;
  bool isSundayChecked = true;
  TextEditingController beginTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  Map<String, String> workingHours = {
    'fri': '09:00 - 18:00',
    'mon': '09:00 - 18:00',
    'sat': '09:00 - 18:00',
    'sun': '09:00 - 18:00',
    'thurs': '09:00 - 18:00',
    'tue': '09:00 - 18:00',
    'wed': '09:00 - 17:00',
  };

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(tr.sign_up.back, style: Typographies.regularBody),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 24),
                Text(
                  tr.sign_up.profile_settings_title,
                  style: Typographies.boldH1,
                ),
                SizedBox(height: 8),
                Text(
                  tr.sign_up.profile_settings_title_desc,
                  style: Typographies.regularBody,
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: LightAppColors.secondaryBg,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22.5),
                        child: Column(
                          children: [
                            AppIcons.icProfile,
                            SizedBox(height: 8),
                            Text(
                              tr.sign_up.upload_photo,
                              style: Typographies.regularBody2,
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: AppIcons.icCamera,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: LightAppColors.secondaryBg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.sign_up.main_desc),
                      SizedBox(height: 16),
                      InputField.text(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required.';
                          }
                          return null;
                        },
                        hintText: tr.sign_up.enter_full_fio,
                        fieldTitle: tr.sign_up.name,
                        controller: nameController,
                      ),
                      SizedBox(height: 16),
                      BlocListener<MasterBloc, MasterState>(
                        listener: (context, state) {
                          if (state is ServiceTypeLoaded) {
                            showBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    itemCount: state.data.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          serviceTypeController.text =
                                              state.data[index].nameRu;
                                          context.pop();
                                        },
                                        child: Text(state.data[index].nameRu),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: InputField.selectableInput(
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                          hintText: tr.sign_up.service_type_hint,
                          fieldTitle: tr.sign_up.service_type,
                          controller: serviceTypeController,
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          onTap: () {
                            BlocProvider.of<MasterBloc>(
                              context,
                            ).add(GetServiceTypes());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: LightAppColors.secondaryBg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.sign_up.work_schedule,
                        style: Typographies.regularH3,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.monday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isMondayChecked,
                              onChanged: (value) {
                                isMondayChecked = !isMondayChecked;
                                if (isMondayChecked) {
                                  workingHours['mon'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.tuesday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isTuesdayChecked,
                              onChanged: (value) {
                                isTuesdayChecked = !isTuesdayChecked;
                                if (isMondayChecked) {
                                  workingHours['tue'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.wednesday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isWednesdayChecked,
                              onChanged: (value) {
                                isWednesdayChecked = !isWednesdayChecked;
                                if (isMondayChecked) {
                                  workingHours['wed'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.thursday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isThursdayChecked,
                              onChanged: (value) {
                                isThursdayChecked = !isThursdayChecked;
                                if (isMondayChecked) {
                                  workingHours['thurs'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.friday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isFridayChecked,
                              onChanged: (value) {
                                isFridayChecked = !isFridayChecked;
                                if (isMondayChecked) {
                                  workingHours['fri'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.saturday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isSaturdayChecked,
                              onChanged: (value) {
                                isSaturdayChecked = !isSaturdayChecked;
                                if (isMondayChecked) {
                                  workingHours['sat'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.sunday,
                            style: Typographies.regularBody.copyWith(
                              color: LightTextColor.secondary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isSundayChecked,
                              onChanged: (value) {
                                isSundayChecked = !isSundayChecked;
                                if (isMondayChecked) {
                                  workingHours['sun'] =
                                      '${beginTimeController.text} - ${endTimeController.text}';
                                }
                                setState(() {});
                              },
                              activeTrackColor: LightAppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputField.time(
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'This field is required.';
                                }
                                return null;
                              },
                              fieldTitle: tr.sign_up.begin_time,
                              suffixIcon: AppIcons.icWatch,
                              controller: beginTimeController,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InputField.time(
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'This field is required.';
                                }
                                return null;
                              },
                              fieldTitle: tr.sign_up.end_time,
                              suffixIcon: AppIcons.icWatch,
                              controller: endTimeController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                MainButton.primary(
                  title: tr.sign_up.complete_settings,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      BlocProvider.of<MasterBloc>(context).add(
                        UpdateMasterProfile(
                          masterProfile: MasterProfile(
                            name: nameController.text,
                            serviceType: serviceTypeController.text,
                            workingHours: workingHours,
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
