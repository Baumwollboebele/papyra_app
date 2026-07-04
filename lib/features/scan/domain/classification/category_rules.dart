import '../../../../core/database/default_categories.dart';

/// Weight tiers for keyword evidence.
abstract final class KeywordWeight {
  const KeywordWeight._();

  /// Highly specific term that alone strongly implies the category.
  static const double strong = 3;

  /// Fairly specific term.
  static const double medium = 2;

  /// Indicative but common term.
  static const double weak = 1;
}

/// A single weighted keyword. The [term] is written naturally (German); it is
/// normalized (umlaut folding, lowercasing) at load time and matched as a
/// leading-boundary prefix so it also fires inside German compounds
/// (`rechnung` matches `Rechnungsnummer`).
class Keyword {
  const Keyword(this.term, this.weight);
  final String term;
  final double weight;
}

/// The keyword rules for one category.
class CategoryRule {
  const CategoryRule(this.key, this.keywords);
  final String key;
  final List<Keyword> keywords;
}

const _s = KeywordWeight.strong;
const _m = KeywordWeight.medium;
const _w = KeywordWeight.weak;

/// Rule set for the 9 default categories. `sonstiges` has no keywords: it is the
/// fallback used when nothing scores.
const List<CategoryRule> kCategoryRules = [
  CategoryRule(CategoryKeys.rechnungen, [
    Keyword('rechnungsnummer', _s),
    Keyword('rechnungsbetrag', _s),
    Keyword('rechnungsdatum', _s),
    Keyword('zahlungsziel', _s),
    Keyword('zahlbar bis', _s),
    Keyword('rechnung', _m),
    Keyword('gesamtbetrag', _m),
    Keyword('zu zahlen', _m),
    Keyword('mwst', _m),
    Keyword('ust', _m),
    Keyword('umsatzsteuer', _m),
    Keyword('netto', _m),
    Keyword('brutto', _m),
    Keyword('leistungsdatum', _m),
    Keyword('rechnungssteller', _m),
    Keyword('betrag', _w),
    Keyword('kundennummer', _w),
    Keyword('faellig', _w),
  ]),
  CategoryRule(CategoryKeys.lohnGehalt, [
    Keyword('lohnsteuerbescheinigung', _s),
    Keyword('entgeltabrechnung', _s),
    Keyword('gehaltsabrechnung', _s),
    Keyword('verdienstabrechnung', _s),
    Keyword('lohnabrechnung', _s),
    Keyword('sozialversicherung', _m),
    Keyword('steuerklasse', _m),
    Keyword('lohnsteuer', _m),
    Keyword('rentenversicherung', _m),
    Keyword('arbeitgeber', _m),
    Keyword('nettoverdienst', _m),
    Keyword('sv-beitrag', _m),
    Keyword('gehalt', _w),
    Keyword('lohn', _w),
    Keyword('abrechnung', _w),
  ]),
  CategoryRule(CategoryKeys.steuern, [
    Keyword('finanzamt', _s),
    Keyword('steuerbescheid', _s),
    Keyword('einkommensteuerbescheid', _s),
    Keyword('steueridentifikationsnummer', _s),
    Keyword('steuernummer', _s),
    Keyword('einkommensteuer', _m),
    Keyword('umsatzsteuererklaerung', _m),
    Keyword('vorauszahlung', _m),
    Keyword('elster', _m),
    Keyword('festsetzung', _m),
    Keyword('steuer', _w),
  ]),
  CategoryRule(CategoryKeys.vertraege, [
    Keyword('vertragsnummer', _s),
    Keyword('kuendigungsfrist', _s),
    Keyword('vertragslaufzeit', _s),
    Keyword('vertragsbeginn', _s),
    Keyword('vertrag', _m),
    Keyword('laufzeit', _m),
    Keyword('kuendigung', _m),
    Keyword('mindestlaufzeit', _m),
    Keyword('vertragspartner', _m),
    Keyword('widerrufsrecht', _m),
    Keyword('agb', _w),
  ]),
  CategoryRule(CategoryKeys.versicherungen, [
    Keyword('versicherungsschein', _s),
    Keyword('versicherungsnummer', _s),
    Keyword('versicherungsnehmer', _s),
    Keyword('police', _s),
    Keyword('versicherung', _m),
    Keyword('beitrag', _m),
    Keyword('tarif', _m),
    Keyword('schadennummer', _m),
    Keyword('haftpflicht', _m),
    Keyword('selbstbeteiligung', _m),
    Keyword('deckung', _w),
  ]),
  CategoryRule(CategoryKeys.bank, [
    Keyword('kontoauszug', _s),
    Keyword('kontostand', _s),
    Keyword('iban', _m),
    Keyword('bic', _m),
    Keyword('sparkasse', _m),
    Keyword('volksbank', _m),
    Keyword('girokonto', _m),
    Keyword('buchung', _m),
    Keyword('saldo', _m),
    Keyword('ueberweisung', _m),
    Keyword('lastschrift', _m),
    Keyword('kreditkarte', _m),
    Keyword('bank', _w),
    Keyword('konto', _w),
  ]),
  CategoryRule(CategoryKeys.gesundheit, [
    Keyword('arztbrief', _s),
    Keyword('krankenkasse', _s),
    Keyword('diagnose', _s),
    Keyword('befund', _s),
    Keyword('arzt', _m),
    Keyword('praxis', _m),
    Keyword('patient', _m),
    Keyword('klinik', _m),
    Keyword('apotheke', _m),
    Keyword('behandlung', _m),
    Keyword('krankenversicherung', _m),
    Keyword('zahnarzt', _m),
    Keyword('rezept', _m),
    Keyword('medikament', _w),
  ]),
  CategoryRule(CategoryKeys.behoerden, [
    Keyword('aktenzeichen', _s),
    Keyword('widerspruch', _s),
    Keyword('verwaltungsakt', _s),
    Keyword('meldebescheinigung', _s),
    Keyword('buergeramt', _m),
    Keyword('ordnungsamt', _m),
    Keyword('behoerde', _m),
    Keyword('antrag', _m),
    Keyword('bescheid', _m),
    Keyword('amt', _w),
    Keyword('gemeinde', _w),
  ]),
];
