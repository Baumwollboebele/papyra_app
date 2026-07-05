import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/features/scan/domain/classification/title_generator.dart';

void main() {
  String gen({String? sender, String? docType, DateTime? date}) =>
      generateTitle(
        template: kDefaultTitleTemplate,
        sender: sender,
        docType: docType,
        date: date,
      );

  test('renders all fields with an ISO date', () {
    expect(
      gen(
        sender: 'Stadtwerke München',
        docType: 'Rechnung',
        date: DateTime(2026, 3, 12),
      ),
      'Stadtwerke München – Rechnung – 2026-03-12',
    );
  });

  test('drops a missing date and its separator', () {
    expect(
      gen(sender: 'Stadtwerke München', docType: 'Rechnung'),
      'Stadtwerke München – Rechnung',
    );
  });

  test('drops a missing sender', () {
    expect(
      gen(docType: 'Rechnung', date: DateTime(2026, 3, 12)),
      'Rechnung – 2026-03-12',
    );
  });

  test('drops two missing fields, leaving one', () {
    expect(gen(sender: 'Allianz'), 'Allianz');
    expect(gen(date: DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('falls back to Dokument when everything is missing', () {
    expect(gen(), 'Dokument');
  });

  test('honors a custom template', () {
    expect(
      generateTitle(
        template: '{date} {docType}',
        docType: 'Vertrag',
        date: DateTime(2026, 3, 12),
      ),
      '2026-03-12 Vertrag',
    );
  });
}
