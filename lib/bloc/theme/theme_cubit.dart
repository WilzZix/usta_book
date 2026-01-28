import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../data/sources/local/shared_pref.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_initialTheme());

  static ThemeMode _initialTheme() {
    final savedTheme = ShredPrefService().getAppThemeMode();
    if (savedTheme == 'dark') return ThemeMode.dark;
    if (savedTheme == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme(bool isDark) {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    ShredPrefService().setAppMode(isDark ? 'dark' : 'light');
    emit(mode);
  }
}
