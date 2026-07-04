import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/features/scan/domain/classification/rule_based_classifier.dart';

void main() {
  final classifier = RuleBasedClassifier();

  void expectCategory(String text, String expectedKey) {
    final result = classifier.classify(text);
    expect(result.bestKey, expectedKey, reason: 'scores: ${result.scores}');
  }

  group('classifies realistic German documents', () {
    test('invoice', () {
      const text = '''
Stadtwerke München GmbH
Rechnung
Rechnungsnummer: 2026-0815
Rechnungsdatum: 12.03.2026
Zahlbar bis 26.03.2026
Nettobetrag 75,55 €
MwSt. 19% 14,35 €
Gesamtbetrag 89,90 €
IBAN DE89 3704 0044 0532 0130 00
''';
      expectCategory(text, CategoryKeys.rechnungen);
      expect(
        classifier.classify(text).isConfident(classifier.confidenceThreshold),
        isTrue,
      );
    });

    test('payslip', () {
      const text = '''
Entgeltabrechnung März 2026
Steuerklasse: 1
Sozialversicherung
Gesetzliche Rentenversicherung
Bruttoverdienst 3.500,00
Nettoverdienst 2.250,45
Arbeitgeber: Beispiel AG
''';
      expectCategory(text, CategoryKeys.lohnGehalt);
    });

    test('tax office notice', () {
      const text = '''
Finanzamt München
Einkommensteuerbescheid für 2025
Steuernummer 143/456/78900
Die Festsetzung ergibt eine Nachzahlung.
''';
      expectCategory(text, CategoryKeys.steuern);
    });

    test('contract', () {
      const text = '''
Mobilfunkvertrag
Vertragsnummer: 998877
Vertragslaufzeit: 24 Monate
Kündigungsfrist: 3 Monate zum Laufzeitende
''';
      expectCategory(text, CategoryKeys.vertraege);
    });

    test('insurance policy', () {
      const text = '''
Allianz Versicherungs-AG
Versicherungsschein
Versicherungsnummer 12/345/678
Versicherungsnehmer: Max Mustermann
Jahresbeitrag Haftpflicht 89,00 €
''';
      expectCategory(text, CategoryKeys.versicherungen);
    });

    test('bank statement', () {
      const text = '''
Sparkasse München
Kontoauszug Nr. 4/2026
Girokonto
Kontostand: 1.234,56 €
Buchung Lastschrift
''';
      expectCategory(text, CategoryKeys.bank);
    });

    test('health', () {
      const text = '''
Zahnarztpraxis Dr. Beispiel
Befund und Diagnose
Behandlung abgeschlossen
Krankenkasse informiert
''';
      expectCategory(text, CategoryKeys.gesundheit);
    });

    test('government/authority', () {
      const text = '''
Bürgeramt der Stadt Köln
Aktenzeichen: ABC-2026-42
Gegen diesen Bescheid können Sie Widerspruch einlegen.
''';
      expectCategory(text, CategoryKeys.behoerden);
    });
  });

  group('confidence & fallback', () {
    test('empty text falls back to sonstiges with zero confidence', () {
      final r = classifier.classify('');
      expect(r.bestKey, CategoryKeys.sonstiges);
      expect(r.confidence, 0);
    });

    test('unrelated text has no evidence', () {
      final r = classifier.classify('Hallo, wie geht es dir heute?');
      expect(r.bestKey, CategoryKeys.sonstiges);
      expect(r.confidence, 0);
    });

    test('a single weak keyword stays below the confidence threshold', () {
      final r = classifier.classify('Der Betrag ist offen.');
      // "betrag" is weak; not enough to auto-classify.
      expect(r.isConfident(classifier.confidenceThreshold), isFalse);
    });

    test('strong, unambiguous evidence is confident', () {
      final r = classifier.classify(
        'Versicherungsschein Police Versicherungsnehmer Haftpflicht',
      );
      expect(r.bestKey, CategoryKeys.versicherungen);
      expect(r.isConfident(classifier.confidenceThreshold), isTrue);
      expect(r.confidence, greaterThan(0.5));
    });

    test('umlaut folding: matches keywords written without umlauts', () {
      final withUmlaut = classifier.classify('Kündigungsfrist beachten');
      final folded = classifier.classify('Kuendigungsfrist beachten');
      expect(withUmlaut.bestKey, CategoryKeys.vertraege);
      expect(folded.bestKey, CategoryKeys.vertraege);
    });

    test('does not false-positive "ust" inside "August"', () {
      final r = classifier.classify('Im August fahren wir in den Urlaub.');
      expect(r.scores[CategoryKeys.rechnungen], 0);
    });

    test('every default category key is present in scores', () {
      final r = classifier.classify('irgendwas');
      for (final c in kDefaultCategories) {
        expect(r.scores.containsKey(c.key), isTrue);
      }
    });
  });
}
