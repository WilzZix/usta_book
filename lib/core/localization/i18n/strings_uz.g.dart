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
			default: return null;
		}
	}
}

