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
import 'package:usta_book/presentation/home/home_page.dart';

import '../../../core/ui_kit/app_theme_extension.dart';
import '../../bottom_nav_bar/bottom_nav_bar.dart';

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
    'mon': '09:00 - 18:00',
    'tue': '09:00 - 18:00',
    'wed': '09:00 - 18:00',
    'thurs': '09:00 - 18:00',
    'fri': '09:00 - 18:00',
    'sat': '09:00 - 18:00',
    'sun': '09:00 - 18:00',
  };
  TimeOfDay _selectedTimeBegin = TimeOfDay.now();
  TimeOfDay _selectedTimeEnd = TimeOfDay.now();

  Future<void> _selectTimeEnd(BuildContext context) async {
    final tr = Translations.of(context);
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTimeEnd);

    if (picked != null && picked != _selectedTimeEnd) {
      // 1. Convert TimeOfDay to a comparable value (e.g., minutes since midnight)
      int beginMinutes = _selectedTimeBegin.hour * 60 + _selectedTimeBegin.minute;
      int pickedMinutes = picked.hour * 60 + picked.minute;

      // 2. Check if the picked time is strictly *after* the begin time
      if (pickedMinutes > beginMinutes) {
        setState(() {
          _selectedTimeEnd = picked;
          // Format the time for the controller
          // Note: You might want to use a package like `intl` for better formatting,
          // especially for adding leading zeros (e.g., 09:05).
          endTimeController.text = '${_selectedTimeEnd.hour}:${_selectedTimeEnd.minute.toString().padLeft(2, '0')}';
          _updateWorkingHours();
        });
      } else {
        // 3. Optional: Show an error message to the user
        // You'll need to implement this `_showTimeError` function.
        _showTimeError(context, tr.sign_up.choose_time);
      }
    }
  }

  // ---

  // You'll need to add a helper function to show an error, like this:
  void _showTimeError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3), backgroundColor: Colors.red));
  }

  // Note: You should also update your _selectTimeBegin to use a proper formatting
  // for minutes (e.g., with a leading zero).
  Future<void> _selectTimeBegin(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTimeBegin);
    if (picked != null && picked != _selectedTimeBegin) {
      setState(() {
        _selectedTimeBegin = picked;
        beginTimeController.text = '${_selectedTimeBegin.hour}:${_selectedTimeBegin.minute.toString().padLeft(2, '0')}';
        _updateWorkingHours();
      });
    }
  }

  // Добавьте эту функцию внутрь _ProfileSettingsState
  void _updateWorkingHours() {
    // Получаем новый диапазон времени
    final newBeginTime = beginTimeController.text;
    final newEndTime = endTimeController.text;

    // Формируем новую строку времени, проверяя, что оба поля заполнены
    final newTimeRange = (newBeginTime.isNotEmpty && newEndTime.isNotEmpty)
        ? '$newBeginTime - $newEndTime'
        : '09:00 - 18:00'; // Запасной вариант

    // Определяем, какие дни сейчас активны, и обновляем их
    if (isMondayChecked) workingHours['mon'] = newTimeRange;
    if (isTuesdayChecked) workingHours['tue'] = newTimeRange;
    if (isWednesdayChecked) workingHours['wed'] = newTimeRange;
    if (isThursdayChecked) workingHours['thurs'] = newTimeRange;
    if (isFridayChecked) workingHours['fri'] = newTimeRange;
    if (isSaturdayChecked) workingHours['sat'] = newTimeRange;
    if (isSundayChecked) workingHours['sun'] = newTimeRange;
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(tr.sign_up.back, style: Typographies.regularBody),
        backgroundColor: custom.body,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Text(tr.sign_up.profile_settings_title, style: Typographies.boldH1),
                SizedBox(height: 8),
                Text(tr.sign_up.profile_settings_title_desc, style: Typographies.regularBody),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.secondary),
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
                            Text(tr.sign_up.upload_photo, style: Typographies.regularBody2),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(padding: const EdgeInsets.only(top: 10.0, right: 10), child: AppIcons.icCamera),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.secondary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.sign_up.main_desc),
                      SizedBox(height: 16),
                      InputField.text(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return tr.sign_up.required_field;
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
                              backgroundColor: custom.secondary,
                              builder: (context) {
                                return SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    itemCount: state.data.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          serviceTypeController.text = state.data[index].nameRu;
                                          context.pop();
                                        },
                                        child: Text(
                                          state.data[index].nameRu,
                                          style: Typographies.regularInput.copyWith(color: TextColor.primary),
                                        ),
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
                              return tr.sign_up.required_field;
                            }
                            return null;
                          },
                          hintText: tr.sign_up.service_type_hint,
                          fieldTitle: tr.sign_up.service_type,
                          controller: serviceTypeController,
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          onTap: () {
                            BlocProvider.of<MasterBloc>(context).add(GetServiceTypes());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.secondary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.sign_up.work_schedule, style: Typographies.regularH3),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(tr.sign_up.monday, style: Typographies.regularBody.copyWith(color: TextColor.secondary)),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isMondayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isMondayChecked = !isMondayChecked; // Обновляем состояние
                                  const dayKey = 'mon';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.tuesday,
                            style: Typographies.regularBody.copyWith(color: TextColor.secondary),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isTuesdayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isTuesdayChecked = !isTuesdayChecked; // Обновляем состояние
                                  const dayKey = 'tue';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.wednesday,
                            style: Typographies.regularBody.copyWith(color: TextColor.secondary),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isWednesdayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isWednesdayChecked = !isWednesdayChecked; // Обновляем состояние
                                  const dayKey = 'wed';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.thursday,
                            style: Typographies.regularBody.copyWith(color: TextColor.secondary),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isThursdayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isThursdayChecked = !isThursdayChecked; // Обновляем состояние
                                  const dayKey = 'thurs';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(tr.sign_up.friday, style: Typographies.regularBody.copyWith(color: TextColor.secondary)),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isFridayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isFridayChecked = !isFridayChecked; // Обновляем состояние
                                  const dayKey = 'fri';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            tr.sign_up.saturday,
                            style: Typographies.regularBody.copyWith(color: TextColor.secondary),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isSaturdayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isSaturdayChecked = !isSaturdayChecked; // Обновляем состояние
                                  const dayKey = 'sat';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(tr.sign_up.sunday, style: Typographies.regularBody.copyWith(color: TextColor.secondary)),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CupertinoSwitch(
                              value: isSundayChecked,
                              onChanged: (value) {
                                setState(() {
                                  isSundayChecked = !isSundayChecked; // Обновляем состояние
                                  const dayKey = 'sun';
                                  if (value) {
                                    // ЕСЛИ ВКЛЮЧИЛИ: Добавляем или обновляем время
                                    final timeRange = '${beginTimeController.text} - ${endTimeController.text}';
                                    workingHours[dayKey] = timeRange.isEmpty
                                        ? '09:00 - 18:00'
                                        : timeRange; // Убедитесь, что время не пустое
                                  } else {
                                    // ЕСЛИ ВЫКЛЮЧИЛИ: Удаляем день из списка
                                    workingHours.remove(dayKey);
                                  }
                                });
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputField.selectableInput(
                              onTap: () async => _selectTimeBegin(context),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return tr.sign_up.required_field;
                                }
                                return null;
                              },
                              fieldTitle: tr.sign_up.begin_time,
                              suffixIcon: AppIcons.icWatch,
                              controller: beginTimeController,
                              hintText: '09:00',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InputField.selectableInput(
                              onTap: () async => _selectTimeEnd(context),
                              hintText: '18:00',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return tr.sign_up.required_field;
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
                BlocListener<MasterBloc, MasterState>(
                  listener: (context, state) {
                    if (state is MasterProfileUpdated) {
                      context.read<AuthCubit>().setProfileComplete();
                      context.go(MainHomeScreen.tag);
                    }
                  },
                  child: BlocBuilder<MasterBloc, MasterState>(
                    builder: (context, state) {
                      return MainButton.primary(
                        isLoading: state is MasterProfileUpdating,
                        title: tr.sign_up.complete_settings,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<MasterBloc>(context).add(
                              UpdateMasterProfile(
                                masterProfile: MasterProfile(
                                  name: nameController.text,
                                  serviceType: serviceTypeController.text,
                                  workingHours: workingHours,
                                  profileCompleted: true,
                                  uid: '',
                                  totalClients: 0,
                                  totalEarning: '',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
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
