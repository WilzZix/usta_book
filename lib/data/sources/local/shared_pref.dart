import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefString {
  static String masterUID = 'masterUID';
  static String themeMode = 'theme_mode';
  static String appLocal = 'app_local';
}

@LazySingleton()
class ShredPrefService {
  // Static instance of LocalPreferences
  static ShredPrefService? _instance;

  // SharedPreferences instance
  late SharedPreferences _preferences;

  // Private constructor to prevent direct instantiation
  ShredPrefService._internal();

  // Factory constructor to provide a single instance
  factory ShredPrefService() {
    _instance ??= ShredPrefService._internal();
    return _instance!;
  }

  // Method to initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> setMasterUID({required String masterUID}) async {
    await _preferences.setString(SharedPrefString.masterUID, masterUID);
  }

  String? getMasterUID() {
    return _preferences.getString(SharedPrefString.masterUID);
  }

  Future<void> setAppMode(String mode) async {
    await _preferences.setString(SharedPrefString.themeMode, mode);
  }

  String? getAppThemeMode() {
    return _preferences.getString(SharedPrefString.themeMode);
  }

  Future<void> setLanguage(String languageCode) async {
    await _preferences.setString(SharedPrefString.appLocal, languageCode);
  }

  String? getLanguage() {
    return _preferences.getString(SharedPrefString.appLocal);
  }
}
