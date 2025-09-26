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
			default: return null;
		}
	}
}

