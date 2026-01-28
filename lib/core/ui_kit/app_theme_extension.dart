import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primary;
  final Color body;
  final Color border;
  final Color success;
  final Color error;

  AppThemeExtension({
    required this.primary,
    required this.body,
    required this.border,
    required this.success,
    required this.error,
  });

  @override
  AppThemeExtension copyWith({Color? primary, Color? body, Color? border, Color? success, Color? error}) {
    return AppThemeExtension(
      primary: primary ?? this.primary,
      body: body ?? this.body,
      border: border ?? this.border,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      body: Color.lerp(body, other.body, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}