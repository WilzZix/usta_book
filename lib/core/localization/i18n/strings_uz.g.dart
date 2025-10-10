///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsUz extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsUz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsUz _root = this; // ignore: unused_field

	@override 
	TranslationsUz $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsUz(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsOnBoardingUz on_boarding = TranslationsOnBoardingUz._(_root);
	@override late final TranslationsButtonsUz buttons = TranslationsButtonsUz._(_root);
	@override late final TranslationsInputFieldUz input_field = TranslationsInputFieldUz._(_root);
	@override late final TranslationsSignUpUz sign_up = TranslationsSignUpUz._(_root);
	@override late final TranslationsHomeUz home = TranslationsHomeUz._(_root);
}

// Path: on_boarding
class TranslationsOnBoardingUz extends TranslationsOnBoardingRu {
	TranslationsOnBoardingUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get choose_language => 'Tilni tanlang';
	@override String get choose_lang_desc => 'Qulay tilingizni belgilang';
	@override String get always_be_aware => 'Doimiy xabardor bo\'ling';
	@override String get always_be_aware_desc => 'Mijoz eslatmalari va yangi yozuvlarni o\'z\n vaqtida oling.';
	@override String get manage_costumers => 'Mijozlarni boshqatish oson';
	@override String get manage_costumers_desc => 'Yozuv qo\'shing,jadvalingizni kuzating va uchrashuvlarni unutib qo\'ymang.';
}

// Path: buttons
class TranslationsButtonsUz extends TranslationsButtonsRu {
	TranslationsButtonsUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get kContinue => 'Davom etish';
	@override String get allow => 'Ruhsat berish';
	@override String get begin => 'Boshlash';
	@override String get send_code_phone_number => 'Tasdiqlash kodi yuborish';
	@override String get confirm_and_continue => 'Tasdiqlash va davom etish';
}

// Path: input_field
class TranslationsInputFieldUz extends TranslationsInputFieldRu {
	TranslationsInputFieldUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get phone_field => 'Telefon raqam';
	@override String get email_field => 'Elektron pochta';
	@override String get password_field => 'Parol';
}

// Path: sign_up
class TranslationsSignUpUz extends TranslationsSignUpRu {
	TranslationsSignUpUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'UstaBookga hush kelibsiz!';
	@override String get welcome_desc => 'Boshlash uchun telefon raqamingizni kiriting.';
	@override String get user_privacy => 'Sizning ma\'lumotlaringiz xavfsiz va biz sizning ma\'lumotlaringizni hech qachon baham ko\'rmaymiz';
	@override String get back => 'Ortga qaytish';
	@override String enter_otp_code({required Object phone}) => '${phone} raqamiga yuborilgan 4 xonali kodni kiriting.';
	@override String timer({required Object time}) => '${time} soniyadan keyin qayta urinib ko\'ring';
	@override String get profile_settings_title => 'O\'zingizning ma\'lumotlaringizni kiriting';
	@override String get profile_settings_title_desc => 'Mijozlarni boshqarishni boshlash uchun profilingizni sozlang.';
	@override String get upload_photo => 'Rasm yuklang';
	@override String get main_desc => 'Asosiy ma\'lumotlar';
	@override String get enter_full_fio => 'To\'liq ism sharifingizni kiriting';
	@override String get service_type => 'Servis turi';
	@override String get service_type_hint => 'Xizmat turini tanlang';
	@override String get work_schedule => 'Ish jadvali';
	@override String get monday => 'Dushanba';
	@override String get tuesday => 'Seshanba';
	@override String get wednesday => 'Chorshanba';
	@override String get thursday => 'Payshanba';
	@override String get friday => 'Juma';
	@override String get saturday => 'Shanba';
	@override String get sunday => 'Yakshanba';
	@override String get begin_time => 'Boshlanish vaqti';
	@override String get end_time => 'Tugash vaqti';
	@override String get complete_settings => 'Sozlashni yakunlash';
	@override String get name => 'Ism';
	@override String get choose_time => 'Tugash vaqti boshlanish vaqtidan keyin bo\'lishi kerak';
	@override String get required_field => 'Bu sohani to\'ldirish shart';
}

// Path: home
class TranslationsHomeUz extends TranslationsHomeRu {
	TranslationsHomeUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get table => 'Jadval';
	@override String get day => 'Kun';
	@override String get week => 'Hafta';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsUz {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'on_boarding.choose_language': return 'Tilni tanlang';
			case 'on_boarding.choose_lang_desc': return 'Qulay tilingizni belgilang';
			case 'on_boarding.always_be_aware': return 'Doimiy xabardor bo\'ling';
			case 'on_boarding.always_be_aware_desc': return 'Mijoz eslatmalari va yangi yozuvlarni o\'z\n vaqtida oling.';
			case 'on_boarding.manage_costumers': return 'Mijozlarni boshqatish oson';
			case 'on_boarding.manage_costumers_desc': return 'Yozuv qo\'shing,jadvalingizni kuzating va uchrashuvlarni unutib qo\'ymang.';
			case 'buttons.kContinue': return 'Davom etish';
			case 'buttons.allow': return 'Ruhsat berish';
			case 'buttons.begin': return 'Boshlash';
			case 'buttons.send_code_phone_number': return 'Tasdiqlash kodi yuborish';
			case 'buttons.confirm_and_continue': return 'Tasdiqlash va davom etish';
			case 'input_field.phone_field': return 'Telefon raqam';
			case 'input_field.email_field': return 'Elektron pochta';
			case 'input_field.password_field': return 'Parol';
			case 'sign_up.welcome': return 'UstaBookga hush kelibsiz!';
			case 'sign_up.welcome_desc': return 'Boshlash uchun telefon raqamingizni kiriting.';
			case 'sign_up.user_privacy': return 'Sizning ma\'lumotlaringiz xavfsiz va biz sizning ma\'lumotlaringizni hech qachon baham ko\'rmaymiz';
			case 'sign_up.back': return 'Ortga qaytish';
			case 'sign_up.enter_otp_code': return ({required Object phone}) => '${phone} raqamiga yuborilgan 4 xonali kodni kiriting.';
			case 'sign_up.timer': return ({required Object time}) => '${time} soniyadan keyin qayta urinib ko\'ring';
			case 'sign_up.profile_settings_title': return 'O\'zingizning ma\'lumotlaringizni kiriting';
			case 'sign_up.profile_settings_title_desc': return 'Mijozlarni boshqarishni boshlash uchun profilingizni sozlang.';
			case 'sign_up.upload_photo': return 'Rasm yuklang';
			case 'sign_up.main_desc': return 'Asosiy ma\'lumotlar';
			case 'sign_up.enter_full_fio': return 'To\'liq ism sharifingizni kiriting';
			case 'sign_up.service_type': return 'Servis turi';
			case 'sign_up.service_type_hint': return 'Xizmat turini tanlang';
			case 'sign_up.work_schedule': return 'Ish jadvali';
			case 'sign_up.monday': return 'Dushanba';
			case 'sign_up.tuesday': return 'Seshanba';
			case 'sign_up.wednesday': return 'Chorshanba';
			case 'sign_up.thursday': return 'Payshanba';
			case 'sign_up.friday': return 'Juma';
			case 'sign_up.saturday': return 'Shanba';
			case 'sign_up.sunday': return 'Yakshanba';
			case 'sign_up.begin_time': return 'Boshlanish vaqti';
			case 'sign_up.end_time': return 'Tugash vaqti';
			case 'sign_up.complete_settings': return 'Sozlashni yakunlash';
			case 'sign_up.name': return 'Ism';
			case 'sign_up.choose_time': return 'Tugash vaqti boshlanish vaqtidan keyin bo\'lishi kerak';
			case 'sign_up.required_field': return 'Bu sohani to\'ldirish shart';
			case 'home.table': return 'Jadval';
			case 'home.day': return 'Kun';
			case 'home.week': return 'Hafta';
			default: return null;
		}
	}
}

