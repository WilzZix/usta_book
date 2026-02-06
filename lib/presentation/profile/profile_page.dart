import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/bottom_sheet.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/presentation/onboarding/choose_language/components/language_item.dart';

import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../core/localization/i18n/strings.g.dart';
import '../../core/ui_kit/app_theme_extension.dart';
import '../../core/ui_kit/components/checkbox.dart';
import '../home/components/loading.dart';

class ProfilePage extends StatefulWidget {
  static String tag = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _State();
}

class _State extends State<ProfilePage> {
  bool appThemeIsDark = false;
  bool isUzbek = false;
  int selectedLanguageItem = 0;
  int selectedThemeItem = 1;

  @override
  void initState() {
    context.read<MasterBloc>().add(GetMasterProfile());
    super.initState();
  }

  String formatScheduleWithContext(BuildContext context, Map<String, String> hours) {
    if (hours.isEmpty) return "";

    final dayOrder = ['mon', 'tue', 'wed', 'thurs', 'fri', 'sat', 'sun'];

    final presentDays = dayOrder.where((day) => hours.containsKey(day)).toList();

    if (presentDays.isEmpty) return "";

    String tr(String key) {
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      final ru = {'mon': 'Пн', 'tue': 'Вт', 'wed': 'Ср', 'thurs': 'Чт', 'fri': 'Пт', 'sat': 'Сб', 'sun': 'Вс'};
      final uz = {
        'mon': 'Dush',
        'tue': 'Seh',
        'wed': 'Chor',
        'thurs': 'Pay',
        'fri': 'Juma',
        'sat': 'Shan',
        'sun': 'Yak',
      };

      return isRu ? (ru[key] ?? key) : (uz[key] ?? key);
    }

    String firstDay = tr(presentDays.first);
    String lastDay = tr(presentDays.last);
    String? timeRange = hours[presentDays.first];

    return "$firstDay - $lastDay: $timeRange";
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: AppBar(title: Text(tr.profile.profile), centerTitle: false, backgroundColor: custom.body),
      body: BlocBuilder<MasterBloc, MasterState>(
        builder: (context, state) {
          if (state is MasterProfileLoadError) {
            return Center(child: Text(state.msg));
          }
          if (state is MasterProfileLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: custom.secondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: custom.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: custom.body),
                            child: AppIcons.icPerson,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.profile?.name ?? '', style: Typographies.regularBody),
                              SizedBox(height: 4),
                              Text(state.profile?.serviceType ?? '', style: Typographies.regularBody2),
                              SizedBox(height: 4),
                              //TODO pastdagi ma'lumotlarni olish uchun function yozish
                              Text(
                                "50 ta mijoz • \$1,500 oylik",
                                style: Typographies.regularOverlineLower.copyWith(color: custom.primary),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: custom.body,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: custom.border),
                            ),
                            child: AppIcons.icEdit,
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
                          Text(tr.profile.settings, style: Typographies.regularH3),
                          SizedBox(height: 16),
                          ProfileItem(
                            icon: AppIcons.icCalendarEvent,
                            title: tr.profile.working_hours,
                            description: formatScheduleWithContext(context, state.profile?.workingHours ?? {}),
                            onTap: () {
                              UstaBookBottomSheet.show(
                                context: context,
                                body: StatefulBuilder(
                                  builder: (context, setState) {
                                    final String currentLang = Localizations.localeOf(context).languageCode;
                                    return Column(
                                      children: state.profile!.workingHours.entries.map((entry) {
                                        final String dayTitle = DayTranslator.translate(entry.key, currentLang);
                                        return WorkingHoursCard(
                                          title: dayTitle,
                                          value: true,
                                          onChanged: (newValue) {
                                            setState(() {});
                                          },
                                          from: '${entry.value.split(" - ")[0]} AM',
                                          to: '${entry.value.split(" - ")[1]} PM',
                                          fromTapped: () {},
                                          toTapped: () {},
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                header: tr.profile.working_hours,
                              );
                            },
                          ),
                          SizedBox(height: 8),
                          ProfileItem(
                            icon: AppIcons.icCalendarEvent,
                            title: tr.profile.app_theme,
                            description: selectedThemeItem == 0 ? tr.profile.night_mode : tr.profile.light_mode,
                            onTap: () {
                              UstaBookBottomSheet.show(
                                context: context,
                                body: StatefulBuilder(
                                  builder: (context, state) {
                                    return Column(
                                      children: [
                                        LanguageItem(
                                          title: tr.profile.night_mode,
                                          selected: selectedThemeItem == 0,
                                          onTap: () {
                                            selectedThemeItem = 0;
                                            appThemeIsDark = true;
                                            BlocProvider.of<ThemeCubit>(context).toggleTheme(appThemeIsDark);
                                            state(() {});
                                          },
                                          icon: Icon(Icons.dark_mode),
                                        ),
                                        SizedBox(height: 8),
                                        LanguageItem(
                                          title: tr.profile.light_mode,
                                          selected: selectedThemeItem == 1,
                                          onTap: () {
                                            selectedThemeItem = 1;
                                            appThemeIsDark = false;
                                            BlocProvider.of<ThemeCubit>(context).toggleTheme(appThemeIsDark);
                                            state(() {});
                                          },
                                          icon: Icon(Icons.light_mode),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                header: tr.profile.change_app_theme,
                              );
                            },
                          ),
                          SizedBox(height: 8),
                          ProfileItem(
                            icon: AppIcons.icCalendarEvent,
                            title: tr.profile.notifications,
                            description: 'Push, SMS, 1 soat ichida',
                            onTap: () {},
                          ),
                          SizedBox(height: 8),
                          ProfileItem(
                            icon: AppIcons.icCalendarEvent,
                            title: tr.profile.language,
                            description: 'Uzbek',
                            onTap: () {
                              UstaBookBottomSheet.show(
                                context: context,
                                body: StatefulBuilder(
                                  builder: (context, state) {
                                    return Column(
                                      children: [
                                        LanguageItem(
                                          title: "O'zbekcha",
                                          selected: selectedLanguageItem == 0,
                                          onTap: () {
                                            selectedLanguageItem = 0;
                                            state(() {});
                                          },
                                          icon: AppIcons.icUzb,
                                        ),
                                        SizedBox(height: 16),
                                        LanguageItem(
                                          title: "Русский",
                                          selected: selectedLanguageItem == 1,
                                          onTap: () {
                                            selectedLanguageItem = 1;
                                            state(() {});
                                          },
                                          icon: AppIcons.icRus,
                                        ),
                                        SizedBox(height: 20),
                                        MainButton.primary(
                                          title: tr.profile.save,
                                          onTap: () {
                                            context.read<ProfileCubit>().changeLocal(
                                              selectedLanguageItem == 1 ? AppLocale.ru : AppLocale.uz,
                                            );
                                            context.pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                header: tr.profile.change_language,
                              );
                            },
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return MainButton.logout(
                          isLoading: state is UserLoggingOutState,
                          title: tr.profile.logout,
                          icon: AppIcons.icLogout,
                          onTap: () {
                            BlocProvider.of<AuthCubit>(context).logOut();
                          },
                        );
                      },
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
          return HomeShimmerLoading();
        },
      ),
    );
  }
}

class ProfileItem extends StatefulWidget {
  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String description;
  final Function() onTap;

  @override
  State<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.body),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.secondary),
              child: widget.icon,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: Typographies.regularBody),
                SizedBox(height: 4),
                Text(widget.description, style: Typographies.regularOverlineLower),
              ],
            ),
            Spacer(),
            Text(tr.profile.configure, style: Typographies.regularOverlineLower.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
