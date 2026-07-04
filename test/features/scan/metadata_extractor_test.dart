import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/features/scan/domain/classification/metadata_extractor.dart';

void main() {
  const ex = MetadataExtractor();

  group('dates', () {
    test('parses dd.MM.yyyy', () {
      expect(
        ex.extractPrimaryDate('Rechnungsdatum: 12.03.2026'),
        DateTime(2026, 3, 12),
      );
    });

    test('parses two-digit year as 2000+', () {
      expect(ex.extractDates('am 01.02.24').single, DateTime(2024, 2, 1));
    });

    test('parses German month names incl. umlaut', () {
      expect(
        ex.extractPrimaryDate('Berlin, den 12. März 2026'),
        DateTime(2026, 3, 12),
      );
      expect(ex.extractPrimaryDate('5. Januar 2025'), DateTime(2025, 1, 5));
    });

    test('rejects impossible dates', () {
      expect(ex.extractDates('31.02.2026'), isEmpty);
      expect(ex.extractDates('45.13.2026'), isEmpty);
    });

    test('prefers the date next to a date keyword', () {
      const text = 'Lieferdatum 01.01.2026\nRechnungsdatum: 15.06.2026';
      expect(ex.extractPrimaryDate(text), DateTime(2026, 6, 15));
    });

    test('returns null when there is no date', () {
      expect(ex.extractPrimaryDate('Kein Datum hier'), isNull);
    });
  });

  group('amounts', () {
    test('parses 1.234,56 into cents', () {
      expect(ex.extractPrimaryAmountCents('Gesamtbetrag 1.234,56 €'), 123456);
    });

    test('parses a plain amount with two decimals', () {
      expect(ex.extractPrimaryAmountCents('Betrag: 89,90 EUR'), 8990);
    });

    test('prefers the amount near a total keyword', () {
      const text = 'Zwischensumme 10,00 €\nGesamtbetrag 119,00 €';
      expect(ex.extractPrimaryAmountCents(text), 11900);
    });

    test('lists all amounts', () {
      expect(ex.extractAmounts('3,50 und 12,00 sowie 1.000,00'), [
        350,
        1200,
        100000,
      ]);
    });

    test('returns null without an amount', () {
      expect(ex.extractPrimaryAmountCents('Keine Zahlen mit Komma'), isNull);
    });
  });

  group('IBAN', () {
    test('extracts and validates a real-format German IBAN', () {
      // Valid mod-97 example IBAN.
      const text = 'Bitte überweisen an DE89 3704 0044 0532 0130 00';
      expect(ex.extractIban(text), 'DE89370400440532013000');
      expect(ex.containsIban(text), isTrue);
    });

    test('rejects an IBAN with a broken checksum', () {
      expect(ex.extractIban('DE00 3704 0044 0532 0130 00'), isNull);
    });

    test('returns null when no IBAN present', () {
      expect(ex.extractIban('Konto 123456'), isNull);
    });
  });

  group('sender', () {
    test('prefers a line with a legal form', () {
      const text =
          'Kundennummer 4711\n'
          'Stadtwerke München GmbH\n'
          'Musterstraße 1';
      expect(ex.extractSender(text), 'Stadtwerke München GmbH');
    });

    test('falls back to the first plausible name line', () {
      const text = '\n  \nDr. med. Anna Beispiel\nArztpraxis';
      expect(ex.extractSender(text), 'Dr. med. Anna Beispiel');
    });

    test('skips leading numeric/date lines', () {
      const text = '12.03.2026\n123\nAllianz Versicherung';
      expect(ex.extractSender(text), 'Allianz Versicherung');
    });
  });

  test('extract() aggregates fields', () {
    const text =
        'Stadtwerke München GmbH\n'
        'Rechnungsdatum: 12.03.2026\n'
        'Gesamtbetrag 89,90 €\n'
        'IBAN DE89 3704 0044 0532 0130 00';
    final md = ex.extract(text);
    expect(md.sender, 'Stadtwerke München GmbH');
    expect(md.documentDate, DateTime(2026, 3, 12));
    expect(md.amountCents, 8990);
    expect(md.iban, 'DE89370400440532013000');
    expect(md.currency, 'EUR');
    expect(md.titleSuggestion, 'Stadtwerke München GmbH');
  });
}
