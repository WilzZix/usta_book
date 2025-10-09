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
class TranslationsRu extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsOnBoardingRu on_boarding = TranslationsOnBoardingRu._(_root);
	@override late final TranslationsButtonsRu buttons = TranslationsButtonsRu._(_root);
	@override late final TranslationsInputFieldRu input_field = TranslationsInputFieldRu._(_root);
	@override late final TranslationsSignUpRu sign_up = TranslationsSignUpRu._(_root);
}

// Path: on_boarding
class TranslationsOnBoardingRu extends TranslationsOnBoardingUz {
	TranslationsOnBoardingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get choose_language => 'Выберите язык';
	@override String get choose_lang_desc => 'Укажите удобный для вас язык';
	@override String get always_be_aware => 'Будьте всегда в курсе';
	@override String get always_be_aware_desc => 'Получайте напоминания и новые записи от клиентов вовремя.';
	@override String get manage_costumers => 'Управлять клиентами легко';
	@override String get manage_costumers_desc => 'Добавляйте записи, следите за расписанием и не забывайте о встречах.';
}

// Path: buttons
class TranslationsButtonsRu extends TranslationsButtonsUz {
	TranslationsButtonsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get kContinue => 'Продолжить';
	@override String get allow => 'Разрешить';
	@override String get begin => 'Начать';
	@override String get send_code_phone_number => 'Отправить код подтверждения';
	@override String get confirm_and_continue => 'Подтвердить и продолжить';
}

// Path: input_field
class TranslationsInputFieldRu extends TranslationsInputFieldUz {
	TranslationsInputFieldRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get phone_field => 'Номер телефона';
	@override String get email_field => 'Электронная почта';
	@override String get password_field => 'Пароль';
}

// Path: sign_up
class TranslationsSignUpRu extends TranslationsSignUpUz {
	TranslationsSignUpRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Добро пожаловать в UstaBook!';
	@override String get welcome_desc => 'Введите свой номер телефона, чтобы начать.';
	@override String get user_privacy => 'Ваши данные в безопасности, и мы никогда не будем ими делиться.';
	@override String get back => 'Назад';
	@override String enter_otp_code({required Object phone}) => 'Введите 4-значный код, отправленный на номер ${phone}.';
	@override String timer({required Object time}) => 'Попробуйте снова через ${time} секунд';
	@override String get profile_settings_title => 'Введите свои данные';
	@override String get profile_settings_title_desc => 'Настройте свой профиль, чтобы начать управлять клиентами.';
	@override String get upload_photo => 'Загрузите фото';
	@override String get main_desc => 'Основные данные';
	@override String get enter_full_fio => 'Введите полное имя';
	@override String get service_type => 'Тип сервиса';
	@override String get service_type_hint => 'Выберите тип услуги';
	@override String get work_schedule => 'График работы';
	@override String get monday => 'Понедельник';
	@override String get tuesday => 'Вторник';
	@override String get wednesday => 'Среда';
	@override String get thursday => 'Четверг';
	@override String get friday => 'Пятница';
	@override String get saturday => 'Суббота';
	@override String get sunday => 'Воскресенье';
	@override String get begin_time => 'Время начала';
	@override String get end_time => 'Время окончания';
	@override String get complete_settings => 'Завершить настройку';
	@override String get name => 'Имя';
	@override String get choose_time => 'Время окончания должно быть позже времени начала';
	@override String get required_field => 'Это поле обязательно для заполнения';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'on_boarding.choose_language': return 'Выберите язык';
			case 'on_boarding.choose_lang_desc': return 'Укажите удобный для вас язык';
			case 'on_boarding.always_be_aware': return 'Будьте всегда в курсе';
			case 'on_boarding.always_be_aware_desc': return 'Получайте напоминания и новые записи от клиентов вовремя.';
			case 'on_boarding.manage_costumers': return 'Управлять клиентами легко';
			case 'on_boarding.manage_costumers_desc': return 'Добавляйте записи, следите за расписанием и не забывайте о встречах.';
			case 'buttons.kContinue': return 'Продолжить';
			case 'buttons.allow': return 'Разрешить';
			case 'buttons.begin': return 'Начать';
			case 'buttons.send_code_phone_number': return 'Отправить код подтверждения';
			case 'buttons.confirm_and_continue': return 'Подтвердить и продолжить';
			case 'input_field.phone_field': return 'Номер телефона';
			case 'input_field.email_field': return 'Электронная почта';
			case 'input_field.password_field': return 'Пароль';
			case 'sign_up.welcome': return 'Добро пожаловать в UstaBook!';
			case 'sign_up.welcome_desc': return 'Введите свой номер телефона, чтобы начать.';
			case 'sign_up.user_privacy': return 'Ваши данные в безопасности, и мы никогда не будем ими делиться.';
			case 'sign_up.back': return 'Назад';
			case 'sign_up.enter_otp_code': return ({required Object phone}) => 'Введите 4-значный код, отправленный на номер ${phone}.';
			case 'sign_up.timer': return ({required Object time}) => 'Попробуйте снова через ${time} секунд';
			case 'sign_up.profile_settings_title': return 'Введите свои данные';
			case 'sign_up.profile_settings_title_desc': return 'Настройте свой профиль, чтобы начать управлять клиентами.';
			case 'sign_up.upload_photo': return 'Загрузите фото';
			case 'sign_up.main_desc': return 'Основные данные';
			case 'sign_up.enter_full_fio': return 'Введите полное имя';
			case 'sign_up.service_type': return 'Тип сервиса';
			case 'sign_up.service_type_hint': return 'Выберите тип услуги';
			case 'sign_up.work_schedule': return 'График работы';
			case 'sign_up.monday': return 'Понедельник';
			case 'sign_up.tuesday': return 'Вторник';
			case 'sign_up.wednesday': return 'Среда';
			case 'sign_up.thursday': return 'Четверг';
			case 'sign_up.friday': return 'Пятница';
			case 'sign_up.saturday': return 'Суббота';
			case 'sign_up.sunday': return 'Воскресенье';
			case 'sign_up.begin_time': return 'Время начала';
			case 'sign_up.end_time': return 'Время окончания';
			case 'sign_up.complete_settings': return 'Завершить настройку';
			case 'sign_up.name': return 'Имя';
			case 'sign_up.choose_time': return 'Время окончания должно быть позже времени начала';
			case 'sign_up.required_field': return 'Это поле обязательно для заполнения';
			default: return null;
		}
	}
}

