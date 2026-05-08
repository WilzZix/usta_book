import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/bottom_sheet.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/presentation/onboarding/choose_language/components/language_item.dart';
import 'package:usta_book/presentation/paywall/paywall_page.dart';
import 'package:usta_book/presentation/sign_up/profile_settings/profile_settings.dart';

import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../core/localization/i18n/strings.g.dart';
import '../../core/ui_kit/app_theme_extension.dart';
import '../home/components/loading.dart';

class ProfilePage extends StatefulWidget {
  static String tag = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _State();
}

class _State extends State<ProfilePage> {
  late int selectedLanguageItem;
  late int selectedThemeItem;

  @override
  void initState() {
    super.initState();
    context.read<MasterBloc>().add(GetMasterProfile());
    selectedLanguageItem = LocaleSettings.currentLocale == AppLocale.ru ? 1 : 0;
    selectedThemeItem = context.read<ThemeCubit>().state == ThemeMode.dark ? 0 : 1;
  }

  String _subscriptionDescription(Translations tr, MasterProfile? profile) {
    if (profile == null) return '';
    switch (profile.subscriptionStatus) {
      case SubscriptionStatus.paid:
        return tr.subscription.status_paid;
      case SubscriptionStatus.trial:
        return tr.subscription.trial_remaining
            .replaceAll('{days}', '${profile.trialDaysRemaining}');
      case SubscriptionStatus.expired:
        return tr.subscription.trial_expired_short;
      case SubscriptionStatus.notStarted:
        return tr.subscription.status_not_started;
    }
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
                          _ProfileAvatar(
                            photoURL: state.profile?.photoURL,
                            placeholderBg: custom.body,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.profile?.name ?? '', style: Typographies.regularBody),
                                SizedBox(height: 4),
                                Text(state.profile?.serviceType ?? '', style: Typographies.regularBody2),
                                SizedBox(height: 4),
                                Text(
                                  '${state.profile?.totalClients ?? 0} ta mijoz · ${state.profile?.totalEarning ?? '-'} oylik',
                                  style: Typographies.regularOverlineLower.copyWith(color: custom.primary),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pushNamed(ProfileSettings.tag),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: custom.body,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: custom.border),
                              ),
                              child: AppIcons.icEdit,
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
                          Text(tr.profile.settings, style: Typographies.regularH3),
                          SizedBox(height: 16),
                          ProfileItem(
                            icon: AppIcons.icCalendarEvent,
                            title: tr.profile.working_hours,
                            description: formatScheduleWithContext(context, state.profile?.workingHours ?? {}),
                            onTap: () => context.pushNamed(ProfileSettings.tag),
                          ),
                          SizedBox(height: 8),
                          ProfileItem(
                            icon: Icon(Icons.workspace_premium_outlined, color: custom.primary),
                            title: tr.subscription.tariff_item_title,
                            description: _subscriptionDescription(tr, state.profile),
                            onTap: () => context.pushNamed(PaywallPage.tag),
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
                                            BlocProvider.of<ThemeCubit>(context).toggleTheme(true);
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
                                            BlocProvider.of<ThemeCubit>(context).toggleTheme(false);
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
                            description: selectedLanguageItem == 1 ? 'Русский' : "O'zbekcha",
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


class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoURL, required this.placeholderBg});

  final String? photoURL;
  final Color placeholderBg;

  @override
  Widget build(BuildContext context) {
    final hasImage = photoURL != null && photoURL!.isNotEmpty;
    if (hasImage) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: placeholderBg,
        backgroundImage: NetworkImage(photoURL!),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(shape: BoxShape.circle, color: placeholderBg),
      child: AppIcons.icPerson,
    );
  }
}
