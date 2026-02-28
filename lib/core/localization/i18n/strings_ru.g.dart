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

	/// ru: 'Нет'
	String get no => 'Нет';
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

	/// ru: 'Пользователь не найден'
	String get user_not_found => 'Пользователь не найден';

	/// ru: 'Хотите зарегится с этими кредами?'
	String get do_you_want_sign_up_with_this_cred => 'Хотите зарегится с этими кредами?';
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

	/// ru: 'Сегодняшняя статистика'
	String get todays_statistics => 'Сегодняшняя статистика';

	/// ru: 'Клиенты еще не добавлены'
	String get no_customers_added => 'Клиенты еще не добавлены';

	/// ru: 'Добавить клиента'
	String get add_customer => 'Добавить клиента';

	/// ru: 'Клиент не пришел'
	String get client_did_not_come => 'Клиент не пришел';

	/// ru: 'В процессе'
	String get in_progress => 'В процессе';

	/// ru: 'Завершено'
	String get finished => 'Завершено';

	/// ru: 'Завершить'
	String get finish_action => 'Завершить';
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

	/// ru: 'Сохранить'
	String get save => 'Сохранить';

	/// ru: 'Настройки'
	String get settings => 'Настройки';

	/// ru: 'Рабочее время'
	String get working_hours => 'Рабочее время';

	/// ru: 'Тема приложения'
	String get app_theme => 'Тема приложения';

	/// ru: 'Ночная'
	String get night_mode => 'Ночная';

	/// ru: 'Дневная'
	String get light_mode => 'Дневная';

	/// ru: 'Изменить тему приложения'
	String get change_app_theme => 'Изменить тему приложения';

	/// ru: 'Уведомления'
	String get notifications => 'Уведомления';

	/// ru: 'Язык'
	String get language => 'Язык';

	/// ru: 'Изменить язык'
	String get change_language => 'Изменить язык';

	/// ru: 'Настроить'
	String get configure => 'Настроить';
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

	/// ru: 'Клиенты'
	String get customers => 'Клиенты';

	/// ru: 'Список клиентов'
	String get customer_list => 'Список клиентов';

	/// ru: 'Добавить нового клиента'
	String get add_new_customer => 'Добавить нового клиента';

	/// ru: 'Параметры'
	String get parameters => 'Параметры';

	/// ru: 'Количество визитов'
	String get visit_count => 'Количество визитов';

	/// ru: 'Последний визит'
	String get last_visit => 'Последний визит';

	/// ru: 'Общий счет'
	String get total_balance => 'Общий счет';

	/// ru: 'Записаться на прием'
	String get book_appointment => 'Записаться на прием';

	/// ru: 'Связаться'
	String get contact => 'Связаться';

	/// ru: 'История'
	String get history => 'История';

	/// ru: 'Изменить'
	String get edit => 'Изменить';

	/// ru: 'Удалить клиента'
	String get delete_customer => 'Удалить клиента';

	/// ru: 'Данные клиента'
	String get customer_details => 'Данные клиента';

	/// ru: 'Выбрать'
	String get select => 'Выбрать';
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
			case 'buttons.no': return 'Нет';
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
			case 'sign_up.user_not_found': return 'Пользователь не найден';
			case 'sign_up.do_you_want_sign_up_with_this_cred': return 'Хотите зарегится с этими кредами?';
			case 'home.table': return 'Расписание';
			case 'home.day': return 'День';
			case 'home.week': return 'Неделя';
			case 'home.theNearestClient': return 'Ближайший клиент';
			case 'home.todays_statistics': return 'Сегодняшняя статистика';
			case 'home.no_customers_added': return 'Клиенты еще не добавлены';
			case 'home.add_customer': return 'Добавить клиента';
			case 'home.client_did_not_come': return 'Клиент не пришел';
			case 'home.in_progress': return 'В процессе';
			case 'home.finished': return 'Завершено';
			case 'home.finish_action': return 'Завершить';
			case 'profile.profile': return 'Профиль';
			case 'profile.logout': return 'Выход';
			case 'profile.save': return 'Сохранить';
			case 'profile.settings': return 'Настройки';
			case 'profile.working_hours': return 'Рабочее время';
			case 'profile.app_theme': return 'Тема приложения';
			case 'profile.night_mode': return 'Ночная';
			case 'profile.light_mode': return 'Дневная';
			case 'profile.change_app_theme': return 'Изменить тему приложения';
			case 'profile.notifications': return 'Уведомления';
			case 'profile.language': return 'Язык';
			case 'profile.change_language': return 'Изменить язык';
			case 'profile.configure': return 'Настроить';
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
			case 'clients.customers': return 'Клиенты';
			case 'clients.customer_list': return 'Список клиентов';
			case 'clients.add_new_customer': return 'Добавить нового клиента';
			case 'clients.parameters': return 'Параметры';
			case 'clients.visit_count': return 'Количество визитов';
			case 'clients.last_visit': return 'Последний визит';
			case 'clients.total_balance': return 'Общий счет';
			case 'clients.book_appointment': return 'Записаться на прием';
			case 'clients.contact': return 'Связаться';
			case 'clients.history': return 'История';
			case 'clients.edit': return 'Изменить';
			case 'clients.delete_customer': return 'Удалить клиента';
			case 'clients.customer_details': return 'Данные клиента';
			case 'clients.select': return 'Выбрать';
			default: return null;
		}
	}
}

