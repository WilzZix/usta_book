import 'dart:ui';

class LightAppColors {
  static Color primary = Color(0xFF007A7A);
  static Color hover = Color(0xFF007A7A).withValues(alpha: 0.8);
  static Color secondaryBg = Color(0xFFFFFFFF);
  static Color body = Color(0xFFF8F9FA);
  static Color border = Color(0xFFE9E9E9);
}

class DarkAppColors {
  static Color primary = Color(0xFF007A7A);
  static Color hover = Color(0xFF007A7A).withValues(alpha: 0.8);
  static Color secondaryBg = Color(0xFF242424);
  static Color body = Color(0xFF1A1A1A);
  static Color border = Color(0xFF2A2A2A);
}

class LightTextColor {
  static Color primary = Color(0xFF212529);
  static Color secondary = Color(0xFF6C757D);
}

class DarkTextColor {
  static Color primary = Color(0xFFE0E0E0);
  static Color secondary = Color(0xFFA0A0A0);
}

class StateColor {
  static Color success = Color(0xFF28A745);
  static Color warning = Color(0xFFFFC107);
  static Color error = Color(0xFFDC3545);
  static Color info = Color(0xFF17A2B8);
}
