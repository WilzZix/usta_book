import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../core/localization/i18n/strings.g.dart';
import '../../data/sources/local/shared_pref.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final ShredPrefService _prefs = ShredPrefService();

  Future<void> changeLocal(AppLocale newLocale) async {
    try {
      LocaleSettings.setLocale(newLocale);

      // 2. Persist the change
      await _prefs.setLanguage(newLocale.languageTag);

      // 3. (Optional) Update state if your UI needs to react to a specific ProfileState
      emit(ProfileLanguageChanged(newLocale));
    } catch (e) {
      emit(ProfileError("Failed to change language"));
    }
  }
}
