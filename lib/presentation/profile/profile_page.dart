import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: custom.body,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: custom.border),
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
                      color: custom.body,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: custom.border),
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
                      color: custom.body,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: custom.border),
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
              MainButton.logout(
                title: 'Change theme',
                icon: AppIcons.icLogout,
                onTap: () {
                  BlocProvider.of<ThemeCubit>(context).toggleTheme(appThemeIsDark);
                  appThemeIsDark = !appThemeIsDark;
                },
              ),
              SizedBox(height: 24),
              MainButton.primary(
                title: tr.profile.change_language,
                onTap: () {
                  context.read<ProfileCubit>().changeLocal(isUzbek ? AppLocale.ru : AppLocale.uz);
                  isUzbek = !isUzbek;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
