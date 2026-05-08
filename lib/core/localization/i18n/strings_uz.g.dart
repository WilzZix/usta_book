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
	@override late final TranslationsProfileUz profile = TranslationsProfileUz._(_root);
	@override late final TranslationsAddRecordUz add_record = TranslationsAddRecordUz._(_root);
	@override late final TranslationsClientsUz clients = TranslationsClientsUz._(_root);
	@override late final TranslationsStatisticsUz statistics = TranslationsStatisticsUz._(_root);
	@override late final TranslationsSubscriptionUz subscription = TranslationsSubscriptionUz._(_root);
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
	@override String get no => 'Yoq';
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
	@override String enter_otp_code({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting.';
	@override String timer({required Object time}) => '${time} soniyadan keyin qayta urinib ko\'ring';
	@override String get resend => 'Qayta yuborish';
	@override late final TranslationsSignUpErrorsUz errors = TranslationsSignUpErrorsUz._(_root);
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
	@override String get user_not_found => 'Foydalanuvchi topilmadi';
	@override String get do_you_want_sign_up_with_this_cred => 'Ushbu ma\'lumotlar bilan ro\'yxatdan o\'tishni xohlaysizmi?';
}

// Path: home
class TranslationsHomeUz extends TranslationsHomeRu {
	TranslationsHomeUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get table => 'Jadval';
	@override String get day => 'Kun';
	@override String get week => 'Hafta';
	@override String get theNearestClient => 'Eng yaqin uchrashuv';
	@override String get todays_statistics => 'Bugungi statistika';
	@override String get no_customers_added => 'Hali mijoz qoʻshilmagan';
	@override String get add_customer => 'Mijoz qoʻshish';
	@override String get client_did_not_come => 'Mijoz kelmadi';
	@override String get in_progress => 'Jarayonda';
	@override String get finished => 'Tugadi';
	@override String get finish_action => 'Tugatish';
	@override String get todays_clients => 'Bugungi uchrashuvlar';
	@override String get arrival_check_title => 'Mijoz keldimi?';
	@override String get arrival_check_came => 'Keldi';
	@override String get arrival_check_dismiss => 'Keyinroq';
}

// Path: profile
class TranslationsProfileUz extends TranslationsProfileRu {
	TranslationsProfileUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get profile => 'Profil';
	@override String get logout => 'Chiqish';
	@override String get save => 'Saqlash';
	@override String get settings => 'Sozlamalar';
	@override String get working_hours => 'Ish vaqti';
	@override String get app_theme => 'Dastur mavzusi';
	@override String get night_mode => 'Tungi';
	@override String get light_mode => 'Kunduzgi';
	@override String get change_app_theme => 'Dastur mavzusini oʻzgartirish';
	@override String get notifications => 'Bildirishnomalar';
	@override String get language => 'Til';
	@override String get change_language => 'Tilni oʻzgartirish';
	@override String get configure => 'Sozlash';
}

// Path: add_record
class TranslationsAddRecordUz extends TranslationsAddRecordRu {
	TranslationsAddRecordUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get validation_text => 'Bu maydon bo\'sh bo\'lmasligi kerak';
	@override String get add_new_record => 'Yangi mijoz qo\'shish';
	@override String get name => 'Mijoz ismi';
	@override String get name_hint => 'Ism Familiya';
	@override String get number => 'Mijoz raqami';
	@override String get date => 'Sana';
	@override String get time => 'Vaqt';
	@override String get service_type => 'Xizmat turi';
	@override String get service_hint => 'Xizmat turini kiriting';
	@override String get price => 'Narx';
	@override String get price_hint => 'Xizmat narxini kiriting';
	@override String get save => 'Saqlash';
	@override String get record_added_success_txt => 'Yangi mijoz ro\'yhatga qo\'shildi';
	@override String recorded_name({required Object name}) => 'Siz ${name} ismli yangi mijozni ro\'yhatga qo\'shdingiz';
}

// Path: clients
class TranslationsClientsUz extends TranslationsClientsRu {
	TranslationsClientsUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String numberOfVisits({required Object count}) => '${count} ta tashrif';
	@override String get customers => 'Mijozlar';
	@override String get customer_list => 'Mijozlar roʻyxati';
	@override String get add_new_customer => 'Yangi mijoz qoʻshish';
	@override String get parameters => 'Parametrlar';
	@override String get visit_count => 'Tashriflar soni';
	@override String get last_visit => 'Soʻnggi tashrifi';
	@override String get total_balance => 'Umumiy hisob';
	@override String get book_appointment => 'Qabulga yozish';
	@override String get contact => 'Bogʻlanish';
	@override String get history => 'Tarix';
	@override String get edit => 'Oʻzgartirish';
	@override String get delete_customer => 'Mijozni oʻchirish';
	@override String get customer_details => 'Mijoz maʼlumotlari';
	@override String get select => 'Tanlash';
}

// Path: statistics
class TranslationsStatisticsUz extends TranslationsStatisticsRu {
	TranslationsStatisticsUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Statistika';
	@override String get monthly_orders => 'Oylik zakazlar';
	@override String get monthly_revenue => 'Oylik daromad';
	@override String get avg_bill => 'O\'rtacha hisob';
	@override String get retention => 'Mijozlar ishtiroki';
	@override String get top_clients => 'Top mijozlar';
	@override String get popular_service => 'Eng mashhur servis';
	@override String get client_details => 'Mijoz ma\'lumotlari';
	@override String get visits_count => 'Tashriflar soni';
	@override String get last_visit => 'So\'nggi tashrifi';
	@override String get total_spent => 'Umumiy hisob';
	@override String get visits_suffix => 'ta tashrif';
	@override String get times_suffix => 'marotaba';
	@override String get schedule => 'Qabulga yozish';
	@override String get contact => 'Bog\'lanish';
	@override String get history => 'Tarix';
	@override String get edit => 'O\'zgartirish';
	@override String get delete_client => 'Mijozni o\'chirish';
	@override String get no_data => 'Hali ma\'lumot yo\'q';
	@override String get currency_suffix => 'so\'m';
}

// Path: subscription
class TranslationsSubscriptionUz extends TranslationsSubscriptionRu {
	TranslationsSubscriptionUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tarif rejasi';
	@override String get subtitle_trial => 'Sinov muddatingiz davom etmoqda';
	@override String get subtitle_expired => 'Sinov muddati tugadi. Davom etish uchun obuna oling';
	@override String get trial_remaining => 'Trial: {days} kun qoldi';
	@override String get trial_expired_short => 'Sinov tugadi';
	@override String get tariff_monthly_label => 'Oylik';
	@override String get tariff_yearly_label => 'Yillik';
	@override String get tariff_per_month => 'so\'m / oy';
	@override String get tariff_per_year => 'so\'m / yil';
	@override String get save_badge => '2 oy bepul';
	@override String get select_payment_method => 'To\'lov usulini tanlang';
	@override String get soon => 'Tez orada ulanadi';
	@override String get feature_unlimited_records => 'Cheksiz mijoz va yozuvlar';
	@override String get feature_stats => 'To\'liq statistika va analitika';
	@override String get feature_reminders => 'SMS va push bildirishnomalar';
	@override String get feature_support => 'Tezkor qo\'llab-quvvatlash';
	@override String get upgrade_button => 'Obuna olish';
	@override String get upgrade_short => 'Yangilash';
	@override String get tariff_item_title => 'Tarif rejasi';
	@override String get status_paid => 'Faol obuna';
	@override String get status_not_started => 'Sinov mavjud';
}

// Path: sign_up.errors
class TranslationsSignUpErrorsUz extends TranslationsSignUpErrorsRu {
	TranslationsSignUpErrorsUz._(TranslationsUz root) : this._root = root, super.internal(root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get invalid_phone => 'Telefon raqami noto\'g\'ri';
	@override String get too_many_requests => 'Juda ko\'p urinish, keyinroq qayta urining';
	@override String get invalid_code => 'Kod noto\'g\'ri';
	@override String get code_expired => 'Kod muddati tugagan';
	@override String get network => 'Internet ulanishi yo\'q';
	@override String get unknown => 'Xatolik yuz berdi';
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
			case 'buttons.no': return 'Yoq';
			case 'input_field.phone_field': return 'Telefon raqam';
			case 'input_field.email_field': return 'Elektron pochta';
			case 'input_field.password_field': return 'Parol';
			case 'sign_up.welcome': return 'UstaBookga hush kelibsiz!';
			case 'sign_up.welcome_desc': return 'Boshlash uchun telefon raqamingizni kiriting.';
			case 'sign_up.user_privacy': return 'Sizning ma\'lumotlaringiz xavfsiz va biz sizning ma\'lumotlaringizni hech qachon baham ko\'rmaymiz';
			case 'sign_up.back': return 'Ortga qaytish';
			case 'sign_up.enter_otp_code': return ({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting.';
			case 'sign_up.timer': return ({required Object time}) => '${time} soniyadan keyin qayta urinib ko\'ring';
			case 'sign_up.resend': return 'Qayta yuborish';
			case 'sign_up.errors.invalid_phone': return 'Telefon raqami noto\'g\'ri';
			case 'sign_up.errors.too_many_requests': return 'Juda ko\'p urinish, keyinroq qayta urining';
			case 'sign_up.errors.invalid_code': return 'Kod noto\'g\'ri';
			case 'sign_up.errors.code_expired': return 'Kod muddati tugagan';
			case 'sign_up.errors.network': return 'Internet ulanishi yo\'q';
			case 'sign_up.errors.unknown': return 'Xatolik yuz berdi';
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
			case 'sign_up.user_not_found': return 'Foydalanuvchi topilmadi';
			case 'sign_up.do_you_want_sign_up_with_this_cred': return 'Ushbu ma\'lumotlar bilan ro\'yxatdan o\'tishni xohlaysizmi?';
			case 'home.table': return 'Jadval';
			case 'home.day': return 'Kun';
			case 'home.week': return 'Hafta';
			case 'home.theNearestClient': return 'Eng yaqin uchrashuv';
			case 'home.todays_statistics': return 'Bugungi statistika';
			case 'home.no_customers_added': return 'Hali mijoz qoʻshilmagan';
			case 'home.add_customer': return 'Mijoz qoʻshish';
			case 'home.client_did_not_come': return 'Mijoz kelmadi';
			case 'home.in_progress': return 'Jarayonda';
			case 'home.finished': return 'Tugadi';
			case 'home.finish_action': return 'Tugatish';
			case 'home.todays_clients': return 'Bugungi uchrashuvlar';
			case 'home.arrival_check_title': return 'Mijoz keldimi?';
			case 'home.arrival_check_came': return 'Keldi';
			case 'home.arrival_check_dismiss': return 'Keyinroq';
			case 'profile.profile': return 'Profil';
			case 'profile.logout': return 'Chiqish';
			case 'profile.save': return 'Saqlash';
			case 'profile.settings': return 'Sozlamalar';
			case 'profile.working_hours': return 'Ish vaqti';
			case 'profile.app_theme': return 'Dastur mavzusi';
			case 'profile.night_mode': return 'Tungi';
			case 'profile.light_mode': return 'Kunduzgi';
			case 'profile.change_app_theme': return 'Dastur mavzusini oʻzgartirish';
			case 'profile.notifications': return 'Bildirishnomalar';
			case 'profile.language': return 'Til';
			case 'profile.change_language': return 'Tilni oʻzgartirish';
			case 'profile.configure': return 'Sozlash';
			case 'add_record.validation_text': return 'Bu maydon bo\'sh bo\'lmasligi kerak';
			case 'add_record.add_new_record': return 'Yangi mijoz qo\'shish';
			case 'add_record.name': return 'Mijoz ismi';
			case 'add_record.name_hint': return 'Ism Familiya';
			case 'add_record.number': return 'Mijoz raqami';
			case 'add_record.date': return 'Sana';
			case 'add_record.time': return 'Vaqt';
			case 'add_record.service_type': return 'Xizmat turi';
			case 'add_record.service_hint': return 'Xizmat turini kiriting';
			case 'add_record.price': return 'Narx';
			case 'add_record.price_hint': return 'Xizmat narxini kiriting';
			case 'add_record.save': return 'Saqlash';
			case 'add_record.record_added_success_txt': return 'Yangi mijoz ro\'yhatga qo\'shildi';
			case 'add_record.recorded_name': return ({required Object name}) => 'Siz ${name} ismli yangi mijozni ro\'yhatga qo\'shdingiz';
			case 'clients.numberOfVisits': return ({required Object count}) => '${count} ta tashrif';
			case 'clients.customers': return 'Mijozlar';
			case 'clients.customer_list': return 'Mijozlar roʻyxati';
			case 'clients.add_new_customer': return 'Yangi mijoz qoʻshish';
			case 'clients.parameters': return 'Parametrlar';
			case 'clients.visit_count': return 'Tashriflar soni';
			case 'clients.last_visit': return 'Soʻnggi tashrifi';
			case 'clients.total_balance': return 'Umumiy hisob';
			case 'clients.book_appointment': return 'Qabulga yozish';
			case 'clients.contact': return 'Bogʻlanish';
			case 'clients.history': return 'Tarix';
			case 'clients.edit': return 'Oʻzgartirish';
			case 'clients.delete_customer': return 'Mijozni oʻchirish';
			case 'clients.customer_details': return 'Mijoz maʼlumotlari';
			case 'clients.select': return 'Tanlash';
			case 'statistics.title': return 'Statistika';
			case 'statistics.monthly_orders': return 'Oylik zakazlar';
			case 'statistics.monthly_revenue': return 'Oylik daromad';
			case 'statistics.avg_bill': return 'O\'rtacha hisob';
			case 'statistics.retention': return 'Mijozlar ishtiroki';
			case 'statistics.top_clients': return 'Top mijozlar';
			case 'statistics.popular_service': return 'Eng mashhur servis';
			case 'statistics.client_details': return 'Mijoz ma\'lumotlari';
			case 'statistics.visits_count': return 'Tashriflar soni';
			case 'statistics.last_visit': return 'So\'nggi tashrifi';
			case 'statistics.total_spent': return 'Umumiy hisob';
			case 'statistics.visits_suffix': return 'ta tashrif';
			case 'statistics.times_suffix': return 'marotaba';
			case 'statistics.schedule': return 'Qabulga yozish';
			case 'statistics.contact': return 'Bog\'lanish';
			case 'statistics.history': return 'Tarix';
			case 'statistics.edit': return 'O\'zgartirish';
			case 'statistics.delete_client': return 'Mijozni o\'chirish';
			case 'statistics.no_data': return 'Hali ma\'lumot yo\'q';
			case 'statistics.currency_suffix': return 'so\'m';
			case 'subscription.title': return 'Tarif rejasi';
			case 'subscription.subtitle_trial': return 'Sinov muddatingiz davom etmoqda';
			case 'subscription.subtitle_expired': return 'Sinov muddati tugadi. Davom etish uchun obuna oling';
			case 'subscription.trial_remaining': return 'Trial: {days} kun qoldi';
			case 'subscription.trial_expired_short': return 'Sinov tugadi';
			case 'subscription.tariff_monthly_label': return 'Oylik';
			case 'subscription.tariff_yearly_label': return 'Yillik';
			case 'subscription.tariff_per_month': return 'so\'m / oy';
			case 'subscription.tariff_per_year': return 'so\'m / yil';
			case 'subscription.save_badge': return '2 oy bepul';
			case 'subscription.select_payment_method': return 'To\'lov usulini tanlang';
			case 'subscription.soon': return 'Tez orada ulanadi';
			case 'subscription.feature_unlimited_records': return 'Cheksiz mijoz va yozuvlar';
			case 'subscription.feature_stats': return 'To\'liq statistika va analitika';
			case 'subscription.feature_reminders': return 'SMS va push bildirishnomalar';
			case 'subscription.feature_support': return 'Tezkor qo\'llab-quvvatlash';
			case 'subscription.upgrade_button': return 'Obuna olish';
			case 'subscription.upgrade_short': return 'Yangilash';
			case 'subscription.tariff_item_title': return 'Tarif rejasi';
			case 'subscription.status_paid': return 'Faol obuna';
			case 'subscription.status_not_started': return 'Sinov mavjud';
			default: return null;
		}
	}
}

