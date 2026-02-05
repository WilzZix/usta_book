import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
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
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      appBar: AppBar(title: Text(tr.profile.profile), centerTitle: false, backgroundColor: custom.body),
      body: SingleChildScrollView(
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
                        Text('Barotov Nodirbek', style: Typographies.regularBody),
                        SizedBox(height: 4),
                        Text('Sartarosh', style: Typographies.regularBody2),
                        SizedBox(height: 4),
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Container(
              //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              //       decoration: BoxDecoration(
              //         color: custom.secondary,
              //         borderRadius: BorderRadius.circular(8),
              //         border: Border.all(color: custom.border),
              //       ),
              //       child: Column(
              //         children: [
              //           Text('4,8', style: Typographies.regularH3),
              //           SizedBox(height: 8),
              //           Text('O’rtacha reyting', style: Typographies.regularBody2),
              //         ],
              //       ),
              //     ),
              //
              //     Container(
              //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              //       decoration: BoxDecoration(
              //         color: custom.secondary,
              //         borderRadius: BorderRadius.circular(8),
              //         border: Border.all(color: custom.border),
              //       ),
              //       child: Column(
              //         children: [
              //           Text('92%', style: Typographies.regularH3),
              //           SizedBox(height: 8),
              //           Text('Mijozlar ishtiroki', style: Typographies.regularBody2),
              //         ],
              //       ),
              //     ),
              //
              //     Container(
              //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              //       decoration: BoxDecoration(
              //         color: custom.secondary,
              //         borderRadius: BorderRadius.circular(8),
              //         border: Border.all(color: custom.border),
              //       ),
              //       child: Column(
              //         children: [
              //           Text('\$500', style: Typographies.regularH3),
              //           SizedBox(height: 8),
              //           Text("O'rtacha hisob", style: Typographies.regularBody2),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              //   decoration: BoxDecoration(
              //     color: custom.secondary,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: custom.border),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Analitika', style: Typographies.regularH3),
              //       SizedBox(height: 16),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Column(
              //             children: [
              //               Text('50', style: Typographies.regularBody2),
              //               SizedBox(height: 8),
              //               Text(
              //                 'Mijozlar ishtiroki',
              //                 style: Typographies.regularOverlineLower.copyWith(color: TextColor.secondary),
              //               ),
              //             ],
              //           ),
              //           Column(
              //             children: [
              //               Text('\$500', style: Typographies.regularBody2),
              //               SizedBox(height: 8),
              //               Text(
              //                 'Foyda',
              //                 style: Typographies.regularOverlineLower.copyWith(color: TextColor.secondary),
              //               ),
              //             ],
              //           ),
              //           Column(
              //             children: [
              //               Text('Soch kesish', style: Typographies.regularBody2),
              //               SizedBox(height: 8),
              //               Text(
              //                 'Mashhur servis',
              //                 style: Typographies.regularOverlineLower.copyWith(color: TextColor.secondary),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.secondary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sozlamalar', style: Typographies.regularH3),
                    SizedBox(height: 16),
                    ProfileItem(
                      icon: AppIcons.icCalendarEvent,
                      title: 'Ish vaqti',
                      description: 'Dush - Shan: 09:00 - 18:00',
                      onTap: () {},
                    ),
                    SizedBox(height: 8),
                    ProfileItem(
                      icon: AppIcons.icCalendarEvent,
                      title: 'Dastur temasi',
                      description: 'Tungi',
                      onTap: () {
                        UstaBookBottomSheet.show(
                          context: context,
                          body: StatefulBuilder(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  LanguageItem(
                                    title: "Tungi",
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
                                    title: "Tongi",
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
                          header: 'Dastur temasini uzgartirish',
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    ProfileItem(
                      icon: AppIcons.icCalendarEvent,
                      title: 'Bildirishnomalar',
                      description: 'Push, SMS, 1 soat ichida',
                      onTap: () {},
                    ),
                    SizedBox(height: 8),
                    ProfileItem(
                      icon: AppIcons.icCalendarEvent,
                      title: 'Til',
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
                          header: 'Tilni o’zgartirish',
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
            Text('Sozlash', style: Typographies.regularOverlineLower.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
