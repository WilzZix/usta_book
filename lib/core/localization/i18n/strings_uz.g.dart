///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsUz = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final tr = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsOnBoardingUz on_boarding = TranslationsOnBoardingUz.internal(_root);
	late final TranslationsButtonsUz buttons = TranslationsButtonsUz.internal(_root);
	late final TranslationsInputFieldUz input_field = TranslationsInputFieldUz.internal(_root);
	late final TranslationsSignUpUz sign_up = TranslationsSignUpUz.internal(_root);
}

// Path: on_boarding
class TranslationsOnBoardingUz {
	TranslationsOnBoardingUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Tilni tanlang'
	String get choose_language => 'Tilni tanlang';

	/// uz: 'Qulay tilingizni belgilang'
	String get choose_lang_desc => 'Qulay tilingizni belgilang';

	/// uz: 'Doimiy xabardor bo'ling'
	String get always_be_aware => 'Doimiy xabardor bo\'ling';

	/// uz: 'Mijoz eslatmalari va yangi yozuvlarni o'z vaqtida oling.'
	String get always_be_aware_desc => 'Mijoz eslatmalari va yangi yozuvlarni o\'z\n vaqtida oling.';

	/// uz: 'Mijozlarni boshqatish oson'
	String get manage_costumers => 'Mijozlarni boshqatish oson';

	/// uz: 'Yozuv qo'shing,jadvalingizni kuzating va uchrashuvlarni unutib qo'ymang.'
	String get manage_costumers_desc => 'Yozuv qo\'shing,jadvalingizni kuzating va uchrashuvlarni unutib qo\'ymang.';
}

// Path: buttons
class TranslationsButtonsUz {
	TranslationsButtonsUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Davom etish'
	String get kContinue => 'Davom etish';

	/// uz: 'Ruhsat berish'
	String get allow => 'Ruhsat berish';

	/// uz: 'Boshlash'
	String get begin => 'Boshlash';

	/// uz: 'Tasdiqlash kodi yuborish'
	String get send_code_phone_number => 'Tasdiqlash kodi yuborish';

	/// uz: 'Tasdiqlash va davom etish'
	String get confirm_and_continue => 'Tasdiqlash va davom etish';
}

// Path: input_field
class TranslationsInputFieldUz {
	TranslationsInputFieldUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Telefon raqam'
	String get phone_field => 'Telefon raqam';
}

// Path: sign_up
class TranslationsSignUpUz {
	TranslationsSignUpUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'UstaBookga hush kelibsiz!'
	String get welcome => 'UstaBookga hush kelibsiz!';

	/// uz: 'Boshlash uchun telefon raqamingizni kiriting.'
	String get welcome_desc => 'Boshlash uchun telefon raqamingizni kiriting.';

	/// uz: 'Sizning ma'lumotlaringiz xavfsiz va biz sizning ma'lumotlaringizni hech qachon baham ko'rmaymiz'
	String get user_privacy => 'Sizning ma\'lumotlaringiz xavfsiz va biz sizning ma\'lumotlaringizni hech qachon baham ko\'rmaymiz';

	/// uz: 'Ortga qaytish'
	String get back => 'Ortga qaytish';

	/// uz: '$phone raqamiga yuborilgan 4 xonali kodni kiriting.'
	String enter_otp_code({required Object phone}) => '${phone} raqamiga yuborilgan 4 xonali kodni kiriting.';

	/// uz: '$time soniyadan keyin qayta urinib ko'ring'
	String timer({required Object time}) => '${time} soniyadan keyin qayta urinib ko\'ring';

	/// uz: 'O'zingizning ma'lumotlaringizni kiriting'
	String get profile_settings_title => 'O\'zingizning ma\'lumotlaringizni kiriting';

	/// uz: 'Mijozlarni boshqarishni boshlash uchun profilingizni sozlang.'
	String get profile_settings_title_desc => 'Mijozlarni boshqarishni boshlash uchun profilingizni sozlang.';

	/// uz: 'Rasm yuklang'
	String get upload_photo => 'Rasm yuklang';

	/// uz: 'Asosiy ma'lumotlar'
	String get main_desc => 'Asosiy ma\'lumotlar';

	/// uz: 'To'liq ism sharifingizni kiriting'
	String get enter_full_fio => 'To\'liq ism sharifingizni kiriting';

	/// uz: 'Servis turi'
	String get service_type => 'Servis turi';

	/// uz: 'Xizmat turini tanlang'
	String get service_type_hint => 'Xizmat turini tanlang';

	/// uz: 'Ish jadvali'
	String get work_schedule => 'Ish jadvali';

	/// uz: 'Dushanba'
	String get monday => 'Dushanba';

	/// uz: 'Seshanba'
	String get tuesday => 'Seshanba';

	/// uz: 'Chorshanba'
	String get wednesday => 'Chorshanba';

	/// uz: 'Payshanba'
	String get thursday => 'Payshanba';

	/// uz: 'Juma'
	String get friday => 'Juma';

	/// uz: 'Shanba'
	String get saturday => 'Shanba';

	/// uz: 'Yakshanba'
	String get sunday => 'Yakshanba';

	/// uz: 'Boshlanish vaqti'
	String get begin_time => 'Boshlanish vaqti';

	/// uz: 'Tugash vaqti'
	String get end_time => 'Tugash vaqti';

	/// uz: 'Sozlashni yakunlash'
	String get complete_settings => 'Sozlashni yakunlash';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
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
			default: return null;
		}
	}
}

