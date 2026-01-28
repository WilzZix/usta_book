import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme_extension.dart';
import 'colors.dart';

class AppThemes {
  static ThemeData createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Define colors based on brightness
    final primary = Color(0xFF007A7A);
    final scaffoldBg = isDark ? Color(0xFF121212) : Color(0xFFF8F9FA);
    final borderColor = isDark ? Color(0xFF333333) : Color(0xFFE9E9E9);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [
        AppThemeExtension(
          primary: primary,
          body: scaffoldBg,
          border: borderColor,
          success: Color(0xFF28A745),
          error: Color(0xFFDC3545),
        ),
      ],
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        unselectedItemColor: isDark ? Colors.white54 : Colors.grey.shade400,
        selectedItemColor: primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: TextStyle(color: StateColor.error),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: StateColor.error),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: StateColor.error),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        dialHandColor: AppColors.primary,

        // The background color of the selected hour/minute circle
        hourMinuteColor: AppColors.primary,

        // The text color of the selected hour/minute number
        hourMinuteTextColor: Colors.white,

        // The color of the AM/PM selector's background when selected
        dayPeriodColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
        ),

        // The color of the AM/PM text when selected
        dayPeriodTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
