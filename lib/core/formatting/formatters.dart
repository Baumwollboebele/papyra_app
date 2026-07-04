import 'package:intl/intl.dart';

/// Locale used for all user-facing date/number formatting. German is the
/// primary market; kept in one place so it is easy to extend later.
const String kFormatLocale = 'de_DE';

final DateFormat _dateFormat = DateFormat('dd.MM.yyyy', kFormatLocale);
final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', kFormatLocale);

String formatDate(DateTime date) => _dateFormat.format(date);

String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

/// Formats [cents] in [currency] using German conventions ("1.234,56 €").
String formatAmount(int cents, {String currency = 'EUR'}) {
  final format = NumberFormat.currency(
    locale: kFormatLocale,
    symbol: currency == 'EUR' ? '€' : currency,
    decimalDigits: 2,
  );
  return format.format(cents / 100);
}

/// Parses German amount input ("1.234,56" / "89,90 €") into cents, or null.
int? parseAmountToCents(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[^\d.,]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  return (value * 100).round();
}
