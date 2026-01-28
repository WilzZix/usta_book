import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';

import '../../bloc/theme/theme_cubit.dart';
import '../../core/localization/i18n/strings.g.dart';

class ProfilePage extends StatefulWidget {
  static String tag = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _State();
}

class _State extends State<ProfilePage> {
  bool appThemeIsDark = false;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.profile.profile), centerTitle: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return MainButton.logout(
                    isLoading: state is UserLoggingOutState,
                    title: tr.profile.logout,
                    icon: AppIcons.icLogout,
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleTheme(appThemeIsDark);
                      appThemeIsDark = !appThemeIsDark;
                      //   BlocProvider.of<AuthCubit>(context).logOut();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
