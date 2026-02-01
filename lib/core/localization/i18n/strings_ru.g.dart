///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsRu = Translations; // ignore: unused_element
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
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsOnBoardingRu on_boarding = TranslationsOnBoardingRu.internal(_root);
	late final TranslationsButtonsRu buttons = TranslationsButtonsRu.internal(_root);
	late final TranslationsInputFieldRu input_field = TranslationsInputFieldRu.internal(_root);
	late final TranslationsSignUpRu sign_up = TranslationsSignUpRu.internal(_root);
	late final TranslationsHomeRu home = TranslationsHomeRu.internal(_root);
	late final TranslationsProfileRu profile = TranslationsProfileRu.internal(_root);
	late final TranslationsAddRecordRu add_record = TranslationsAddRecordRu.internal(_root);
	late final TranslationsClientsRu clients = TranslationsClientsRu.internal(_root);
}

// Path: on_boarding
class TranslationsOnBoardingRu {
	TranslationsOnBoardingRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Выберите язык'
	String get choose_language => 'Выберите язык';

	/// ru: 'Укажите удобный для вас язык'
	String get choose_lang_desc => 'Укажите удобный для вас язык';

	/// ru: 'Будьте всегда в курсе'
	String get always_be_aware => 'Будьте всегда в курсе';

	/// ru: 'Получайте напоминания и новые записи от клиентов вовремя.'
	String get always_be_aware_desc => 'Получайте напоминания и новые записи от клиентов вовремя.';

	/// ru: 'Управлять клиентами легко'
	String get manage_costumers => 'Управлять клиентами легко';

	/// ru: 'Добавляйте записи, следите за расписанием и не забывайте о встречах.'
	String get manage_costumers_desc => 'Добавляйте записи, следите за расписанием и не забывайте о встречах.';
}

// Path: buttons
class TranslationsButtonsRu {
	TranslationsButtonsRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Продолжить'
	String get kContinue => 'Продолжить';

	/// ru: 'Разрешить'
	String get allow => 'Разрешить';

	/// ru: 'Начать'
	String get begin => 'Начать';

	/// ru: 'Отправить код подтверждения'
	String get send_code_phone_number => 'Отправить код подтверждения';

	/// ru: 'Подтвердить и продолжить'
	String get confirm_and_continue => 'Подтвердить и продолжить';
}

// Path: input_field
class TranslationsInputFieldRu {
	TranslationsInputFieldRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Номер телефона'
	String get phone_field => 'Номер телефона';

	/// ru: 'Электронная почта'
	String get email_field => 'Электронная почта';

	/// ru: 'Пароль'
	String get password_field => 'Пароль';
}

// Path: sign_up
class TranslationsSignUpRu {
	TranslationsSignUpRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Добро пожаловать в UstaBook!'
	String get welcome => 'Добро пожаловать в UstaBook!';

	/// ru: 'Введите свой номер телефона, чтобы начать.'
	String get welcome_desc => 'Введите свой номер телефона, чтобы начать.';

	/// ru: 'Ваши данные в безопасности, и мы никогда не будем ими делиться.'
	String get user_privacy => 'Ваши данные в безопасности, и мы никогда не будем ими делиться.';

	/// ru: 'Назад'
	String get back => 'Назад';

	/// ru: 'Введите 4-значный код, отправленный на номер $phone.'
	String enter_otp_code({required Object phone}) => 'Введите 4-значный код, отправленный на номер ${phone}.';

	/// ru: 'Попробуйте снова через $time секунд'
	String timer({required Object time}) => 'Попробуйте снова через ${time} секунд';

	/// ru: 'Введите свои данные'
	String get profile_settings_title => 'Введите свои данные';

	/// ru: 'Настройте свой профиль, чтобы начать управлять клиентами.'
	String get profile_settings_title_desc => 'Настройте свой профиль, чтобы начать управлять клиентами.';

	/// ru: 'Загрузите фото'
	String get upload_photo => 'Загрузите фото';

	/// ru: 'Основные данные'
	String get main_desc => 'Основные данные';

	/// ru: 'Введите полное имя'
	String get enter_full_fio => 'Введите полное имя';

	/// ru: 'Тип сервиса'
	String get service_type => 'Тип сервиса';

	/// ru: 'Выберите тип услуги'
	String get service_type_hint => 'Выберите тип услуги';

	/// ru: 'График работы'
	String get work_schedule => 'График работы';

	/// ru: 'Понедельник'
	String get monday => 'Понедельник';

	/// ru: 'Вторник'
	String get tuesday => 'Вторник';

	/// ru: 'Среда'
	String get wednesday => 'Среда';

	/// ru: 'Четверг'
	String get thursday => 'Четверг';

	/// ru: 'Пятница'
	String get friday => 'Пятница';

	/// ru: 'Суббота'
	String get saturday => 'Суббота';

	/// ru: 'Воскресенье'
	String get sunday => 'Воскресенье';

	/// ru: 'Время начала'
	String get begin_time => 'Время начала';

	/// ru: 'Время окончания'
	String get end_time => 'Время окончания';

	/// ru: 'Завершить настройку'
	String get complete_settings => 'Завершить настройку';

	/// ru: 'Имя'
	String get name => 'Имя';

	/// ru: 'Время окончания должно быть позже времени начала'
	String get choose_time => 'Время окончания должно быть позже времени начала';

	/// ru: 'Это поле обязательно для заполнения'
	String get required_field => 'Это поле обязательно для заполнения';
}

// Path: home
class TranslationsHomeRu {
	TranslationsHomeRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Расписание'
	String get table => 'Расписание';

	/// ru: 'День'
	String get day => 'День';

	/// ru: 'Неделя'
	String get week => 'Неделя';

	/// ru: 'Ближайший клиент'
	String get theNearestClient => 'Ближайший клиент';
}

// Path: profile
class TranslationsProfileRu {
	TranslationsProfileRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Профиль'
	String get profile => 'Профиль';

	/// ru: 'Выход'
	String get logout => 'Выход';

	/// ru: 'Изменит язык'
	String get change_language => 'Изменит язык';
}

// Path: add_record
class TranslationsAddRecordRu {
	TranslationsAddRecordRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: 'Это поле не должно быть пустым'
	String get validation_text => 'Это поле не должно быть пустым';

	/// ru: 'Добавить нового клиента'
	String get add_new_record => 'Добавить нового клиента';

	/// ru: 'Имя клиента'
	String get name => 'Имя клиента';

	/// ru: 'Имя Фамилия'
	String get name_hint => 'Имя Фамилия';

	/// ru: 'Номер клиента'
	String get number => 'Номер клиента';

	/// ru: 'Дата'
	String get date => 'Дата';

	/// ru: 'Время'
	String get time => 'Время';

	/// ru: 'Тип услуги'
	String get service_type => 'Тип услуги';

	/// ru: 'Введите тип услуги'
	String get service_hint => 'Введите тип услуги';

	/// ru: 'Цена'
	String get price => 'Цена';

	/// ru: 'Введите цену услуги'
	String get price_hint => 'Введите цену услуги';

	/// ru: 'Сохранить'
	String get save => 'Сохранить';

	/// ru: 'Новый клиент добавлен в список'
	String get record_added_success_txt => 'Новый клиент добавлен в список';

	/// ru: 'Вы добавили нового клиента по имени ${name} в список'
	String recorded_name({required Object name}) => 'Вы добавили нового клиента по имени ${name} в список';
}

// Path: clients
class TranslationsClientsRu {
	TranslationsClientsRu.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ru: '${count} посещений'
	String numberOfVisits({required Object count}) => '${count} посещений';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
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
			case 'home.table': return 'Расписание';
			case 'home.day': return 'День';
			case 'home.week': return 'Неделя';
			case 'home.theNearestClient': return 'Ближайший клиент';
			case 'profile.profile': return 'Профиль';
			case 'profile.logout': return 'Выход';
			case 'profile.change_language': return 'Изменит язык';
			case 'add_record.validation_text': return 'Это поле не должно быть пустым';
			case 'add_record.add_new_record': return 'Добавить нового клиента';
			case 'add_record.name': return 'Имя клиента';
			case 'add_record.name_hint': return 'Имя Фамилия';
			case 'add_record.number': return 'Номер клиента';
			case 'add_record.date': return 'Дата';
			case 'add_record.time': return 'Время';
			case 'add_record.service_type': return 'Тип услуги';
			case 'add_record.service_hint': return 'Введите тип услуги';
			case 'add_record.price': return 'Цена';
			case 'add_record.price_hint': return 'Введите цену услуги';
			case 'add_record.save': return 'Сохранить';
			case 'add_record.record_added_success_txt': return 'Новый клиент добавлен в список';
			case 'add_record.recorded_name': return ({required Object name}) => 'Вы добавили нового клиента по имени ${name} в список';
			case 'clients.numberOfVisits': return ({required Object count}) => '${count} посещений';
			default: return null;
		}
	}
}

